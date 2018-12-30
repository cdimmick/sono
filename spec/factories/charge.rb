FactoryBot.define do
  factory :charge do
    email { Faker::Internet.email }
    stripe_id { "_stripe_id" }
    event
  end
end
