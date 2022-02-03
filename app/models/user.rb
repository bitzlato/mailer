# frozen_string_literal: true

class User < ApplicationRecord

  def language
    @language ||=(bitzlato_profile&.lang&.presence || Mailer::App.config.default_language).to_sym
  end

  private

  def bitzlato_profile
    BitzlatoProfile
      .joins(:bitzlato_user)
      .where(bitzlato_user: { real_email: email, email_verified: true, deleted_at: nil })
      .order('bitzlato_user.id DESC')
      .take
  end
end
