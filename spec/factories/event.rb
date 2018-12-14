FactoryBot.define do
  factory :event do
    # admin
    user
    facility

    start_time { Time.now + 1.day }
  end
end
