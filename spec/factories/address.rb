FactoryBot.define do
  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Address::STATES.keys.sample }
    zip{ Faker::Address.zip_code }

    factory :complete_address do
      street2 { Faker::Address.street_address }
      street3 { Faker::Address.street_address }
      number { "# #{Random.rand(1..10000)}" }
    end
  end
end
