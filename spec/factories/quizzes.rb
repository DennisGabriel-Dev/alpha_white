FactoryBot.define do
  factory :quiz do
    title       { Faker::Lorem.sentence(word_count: 3) }
    association :lesson
    association :tenant
  end
end
