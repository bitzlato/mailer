FactoryBot.define do
  factory :bitzlato_profile do
    lang { 'ru' }
    currency { 'USD' }
    generated_name { 'Al Pacino'}
    cryptocurrency { 'BTC' }
    rating { 0 }
  end
end
