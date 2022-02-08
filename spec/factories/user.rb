FactoryBot.define do
  factory :user do
    uid { "1111" }
    email { 'member@example.com' }
    role { 'member' }
    level { 0 }
    password_digest { 'simple password' }
  end
end
