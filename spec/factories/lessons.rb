FactoryBot.define do
  factory :lesson do
    name        { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph }
    video_url   { nil }
    position    { 0 }
    association :session
    association :tenant

    trait :with_video_url do
      video_url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    end
  end
end
