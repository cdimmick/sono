FactoryBot.define do
  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Address::STATES.keys.sample }
    zip{ Faker::Address.zip_code }
  end
end
