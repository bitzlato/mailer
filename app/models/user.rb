# frozen_string_literal: true

# User model
class User < ApplicationRecord

  def language
    if data.blank?
      Mailer::App.config.default_language.upcase
    else
      JSON.parse(data)['language'].upcase || Mailer::App.config.default_language.upcase
    end
  end

end

# == Schema Information
# Schema version: 20210316083841
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  uid             :string(255)      not null
#  username        :string(255)
#  email           :string(255)      not null
#  password_digest :string(255)      not null
#  role            :string(255)      default("member"), not null
#  data            :text(65535)
#  level           :integer          default(0), not null
#  otp             :boolean          default(FALSE)
#  state           :string(255)      default("pending"), not null
#  referral_id     :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_uid       (uid) UNIQUE
#  index_users_on_username  (username) UNIQUE
#
