# frozen_string_literal: true

class Postmaster < ApplicationMailer
  LAYOUTS = {
    p2p: 'p2p'
  }.freeze

  def process_payload(params)
    @record  = params[:record]
    @email    = params[:email]

    sender = "#{::Mailer::App.config.sender_name} <#{::Mailer::App.config.sender_email}>"

    email_options = {
      subject: params[:subject],
      from: sender,
      to: @email
    }
    Rails.logger.info("Sent email from #{sender} to #{@email} with params #{params}")

    I18n.with_locale params[:locale] do
      mail(email_options) do |format|
        format.html do
          render action: params[:template_name], layout: fetch_layout(params[:signer])
        end
      end
    end
  end

  def fetch_layout(signer)
    LAYOUTS.fetch(signer.to_sym, 'mailer')
  end
end
