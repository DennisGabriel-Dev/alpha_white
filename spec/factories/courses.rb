FactoryBot.define do
  factory :course do
    name        { Faker::Educator.course_name }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    active      { true }
    association :tenant

    trait :inactive do active { false } end
  end
end
