FactoryBot.define do
  factory :feedback do
    rating      { rand(1..5) }
    description { Faker::Lorem.sentence }
    association :lesson
    association :user
  end
end
