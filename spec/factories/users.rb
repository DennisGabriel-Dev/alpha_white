FactoryBot.define do
  factory :user do
    email                 { Faker::Internet.unique.email }
    password              { "password123" }
    password_confirmation { "password123" }
    role                  { :student }
    association :tenant

    trait :student        do role { :student }        end
    trait :instructor     do role { :instructor }     end
    trait :tenant_admin   do role { :tenant_admin }   end
    trait :super_admin    do role { :super_admin }     end
  end
end
