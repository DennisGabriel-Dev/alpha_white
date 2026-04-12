FactoryBot.define do
  factory :session do
    name     { Faker::Educator.subject }
    position { 0 }
    association :course
    association :tenant
  end
end
