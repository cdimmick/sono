FactoryBot.define do
  factory :charge do
    email { Faker::Internet.email }
    stripe_token { "_stripe_token" }
    event
  end
end
