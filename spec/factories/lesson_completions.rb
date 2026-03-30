FactoryBot.define do
  factory :lesson_completion do
    video_watched  { false }
    quiz_completed { false }
    association :lesson
    association :user

    trait :video_watched  do video_watched  { true } end
    trait :quiz_completed do quiz_completed { true } end
    trait :completed      do video_watched { true }; quiz_completed { true } end
  end
end
