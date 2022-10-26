# frozen_string_literal: true

require 'bunny'
require 'ostruct'

class EventMailer
  Error = Class.new(StandardError)

  class VerificationError < Error; end

  def initialize(events, exchanges, keychain)
    @events = events
    @exchanges = exchanges
    @keychain = keychain

    Kernel.at_exit { unlisten }
  end

  def call
    listen
  end

  private

  def listen
    unlisten

    @bunny_session = Bunny::Session.new(rabbitmq_credentials).tap do |session|
      session.start
      Kernel.at_exit { session.stop }
    end

    @bunny_channel = @bunny_session.channel
    # Delete old queue if some exists
    @bunny_channel.queue_delete('barong.postmaster.event.mailer') if @bunny_session.queue_exists?('barong.postmaster.event.mailer')

    # Define fanout exchanges which will broadcast
    # all the messages they receives to all the queues they know
    retry_exchange = @bunny_channel.fanout('barong.event.mailer.retry.exchange')
    main_exchange = @bunny_channel.fanout('barong.event.mailer.main.exchange')

    queue = @bunny_channel.queue('barong.event.mailer.main', auto_delete: false, durable: true,
      arguments: {
        :'x-dead-letter-exchange' => retry_exchange.name,
      }
    )
    queue.bind(main_exchange)

    retry_queue = @bunny_channel.queue('barong.event.mailer.retry', auto_delete: false, durable: true,
      arguments: {
        :'x-dead-letter-exchange' => main_exchange.name,
        :'x-message-ttl' => 120000   # will trigger retry every 2 minutes
    })
    retry_queue.bind(retry_exchange)

    @events.each do |event|
      exchange_name = @exchanges[event[:exchange].to_sym][:name]
      exchange = @bunny_channel.direct(exchange_name)

      queue.bind(exchange, routing_key: event[:key])
    end

    Rails.logger.warn { 'Listening for events.' }
    queue.subscribe(manual_ack: true, block: true, &method(:handle_message))
  end

  def unlisten
    if @bunny_session || @bunny_channel
      Rails.logger.warn { 'No longer listening for events.' }
    end

    @bunny_channel&.work_pool&.kill
    @bunny_session&.stop
  ensure
    @bunny_channel = nil
    @bunny_session = nil
  end

  def algorithm_verification_options(signer)
    { algorithms: @keychain[signer][:algorithm] }
  end

  def jwt_public_key(signer)
    OpenSSL::PKey.read(Base64.urlsafe_decode64(@keychain[signer][:value]))
  end

  def rabbitmq_credentials
    Mailer::App.config.event_api_rabbitmq_url
  end

  def handle_message(delivery_info, _metadata, payload)
    Rails.logger.warn { "Start handling a message" }
    Rails.logger.warn { "\nPayload: \n #{payload} \n\n Metadata: \n #{_metadata} \n\n Delivery info: \n #{delivery_info} \n" }
    exchange = @exchanges.select { |_, ex| ex[:name] == delivery_info[:exchange] }

    # In case of retry message
    # we should get exchange name from _metadata info
    if exchange.empty?
      exchange_name = _metadata[:headers]['x-death'][1]['exchange']
      exchange = @exchanges.select { |_, ex| ex[:name] == exchange_name }
    end

    exchange_id = exchange.keys.first.to_s
    signer      = exchange[exchange_id.to_sym][:signer]

    result = verify_jwt(payload, signer.to_sym)

    raise VerificationError, "Failed to verify signature from #{signer}." \
      unless result[:verified].include?(signer.to_sym)

    configs = @events.select do |event|
      event[:key] == delivery_info[:routing_key] &&
        event[:exchange] == exchange_id
    end.presence || raise("No configs found for #{delivery_info}")

    event = result[:payload].fetch(:event)
    obj   = JSON.parse(event.to_json, object_class: OpenStruct)

    user = fetch_user(obj.record.user)

    if user.email.blank?
      Rails.logger.warn { "Skip event from #{signer} without user email. Event payload - #{result[:payload]}" }
      return
    end

    language = user.language

    Rails.logger.warn { "User #{user.email} has '#{language}' email language" }

    configs.each do |config|
      template_config = config.fetch(:templates).transform_keys(&:downcase)

      unless template_config.keys.include?(language)
        Rails.logger.warn { "Language #{language} is not supported. Use #{Mailer::App.config.default_language} language" }
        language = Mailer::App.config.default_language.to_sym
      end

      if config[:expression].present? && skip_event?(event, config[:expression])
        Rails.logger.warn { "Event #{obj.name} skipped by expression - #{config[:expression]}" }
        next
      end

      params = {
        subject: template_config[language][:subject],
        template_name: template_config[language][:template_path],
        email: user.email,
        locale: language,
        record: event[:record],
        changes: event[:changes],
        signer: signer
      }

      if obj.record.wait_until && obj.record.wait_until.to_d > 0 && Time.at(obj.record.wait_until) > 10.seconds.since
        PostmasterWorker.set(wait_until: Time.at(obj.record.wait_until)).perform_later(params)
      else
        PostmasterWorker.perform_now(params)
      end
    end

    # Acknowledges a message
    # Acknowledged message is completely removed from the queue
    @bunny_channel.ack(delivery_info.delivery_tag)
  rescue JWT::ExpiredSignature, JWT::VerificationError, VerificationError => e
    report_exception e
    # Acknowledges a message
    @bunny_channel.ack(delivery_info.delivery_tag)
  rescue StandardError => e
    report_exception e

    # Rejects a message
    # A rejected message dropped by RabbitMQ and goes to dead letter exchange queue
    @bunny_channel.reject(delivery_info.delivery_tag)

    unlisten if db_connection_error?(e)
  end

  def fetch_user(user)
    return User.find_by!(uid: user.uid) if user.uid.present?

    OpenStruct.new(email: user.email, language: user.locale.to_s.to_sym)
  end

  def verify_jwt(payload, signer)
    options = algorithm_verification_options(signer)
    JWT::Multisig.verify_jwt JSON.parse(payload), { signer => jwt_public_key(signer) },
                             options.compact
  end

  def skip_event?(event, expression)
    # valid operators: and / or / not
    operator = expression.keys.first.downcase
    # { field_name: field_value }
    values = expression[operator]

    # return array of boolean [false, true]
    res = values.keys.map do |field_name|
      safe_dig(event, field_name.to_s.split('.')) == values[field_name]
    end

    # all? works as AND operator, any? works as OR operator
    return false if (operator == :and && res.all?) || (operator == :or && res.any?) ||
                    (operator == :not && !res.all?)

    return true if operator == :not && res.all?

    true
  end

  def db_connection_error?(exception)
    (defined?(Mysql2) && (exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error))) ||
      (defined?(PG) && exception.is_a?(PG::Error))
  end

  def safe_dig(hash, keypath, default = nil)
    stringified_hash = JSON.parse(hash.to_json)
    stringified_keypath = keypath.map(&:to_s)

    stringified_keypath.reduce(stringified_hash) do |accessible, key|
      return default unless accessible.is_a? Hash
      return default unless accessible.key? key

      accessible[key]
    end
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end
end
