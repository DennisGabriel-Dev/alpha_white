FactoryBot.define do
  factory :quiz_attempt do
    association :quiz
    association :user, factory: [:user, :student]
    association :tenant
    attempt_number { 1 }
    started_at { Time.current }
    submitted_at { nil }
    duration_seconds { nil }
    time_limit_seconds { 600 }

    trait :submitted do
      submitted_at { Time.current }
      duration_seconds { 120 }
    end
  end
end
