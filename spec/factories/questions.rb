FactoryBot.define do
  factory :question do
    enunciation { Faker::Lorem.question }
    position    { 0 }
    association :quiz
    association :tenant
    enem_question { nil }

    trait :from_enem do
      association :enem_question
    end
  end
end
