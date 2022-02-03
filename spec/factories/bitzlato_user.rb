FactoryBot.define do
  factory :bitzlato_user do
    real_email { 'member@example.com' }
    subject { 'Subject' }
    email_verified { true }
    chat_enabled { false }
    email_auth_enabled { false }
  end
end
