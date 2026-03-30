FactoryBot.define do
  factory :tenant do
    name          { Faker::Company.name }
    subdomain     { "tenant-#{SecureRandom.hex(4)}" }
    primary_color { "#3C0094" }
    theme         { "default" }
    active        { true }

    trait :aurora do
      theme { "aurora" }
    end

    trait :merma do
      theme { "merma" }
    end

    trait :inactive do
      active { false }
    end
  end
end
