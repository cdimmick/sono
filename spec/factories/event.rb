FactoryBot.define do
  factory :event do
    admin
    user

    start_time { Time.now + Random.rand(1..10000).minutes }

    after(:build) do |event|
      event.facility = event.admin.facility 
    end
  end
end
