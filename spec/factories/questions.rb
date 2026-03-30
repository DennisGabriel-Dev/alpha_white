FactoryBot.define do
  factory :question do
    enunciation { Faker::Lorem.question }
    position    { 0 }
    association :quiz
    association :tenant
  end
end
