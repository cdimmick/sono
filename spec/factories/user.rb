FactoryBot.define do
  factory :user do
    sequence(:email){ |n| "test#{n}@test.com" }
    password { ENV.fetch('PW') }

    factory :admin do
      role { 'admin' }
    end

    factory :super_admin do
      role { 'super_admin' }
    end
  end
end
