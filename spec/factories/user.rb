FactoryBot.define do
  factory :user do
    sequence(:email){ |n| "test#{n}@test.com" }
    password { ENV.fetch('PW') }
    name { Faker::Name.name }
    role { 'user' }

    factory :admin do
      role { 'admin' }
      facility
    end

    factory :super_admin do
      role { 'super_admin' }
    end
  end
end
