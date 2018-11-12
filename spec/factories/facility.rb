FactoryBot.define do
  factory :facility do
    name {Faker::Company.name}

    factory :complete_facility do
      phone{ Faker::PhoneNumber.phone_number }

      association :address, factory: :complete_address
    end
  end
end
