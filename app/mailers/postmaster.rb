# frozen_string_literal: true

class Postmaster < ApplicationMailer
  layout 'mailer'

  def process_payload(params)
    @record  = params[:record]
    @changes = params[:changes]
    @user    = params[:user]
    @logo    = params[:logo]

    sender = "#{::Mailer::App.config.sender_name} <#{::Mailer::App.config.sender_email}>"

    email_options = {
      subject: params[:subject],
      from: sender,
      to: @user.email
    }
    Rails.logger.info("Sent email from #{sender} to #{@user.email} with params #{params}")

    I18n.with_locale params[:locale] do
      mail(email_options) do |format|
        format.html do
          render action: params[:template_name]
        end
      end
    end
  end
end
