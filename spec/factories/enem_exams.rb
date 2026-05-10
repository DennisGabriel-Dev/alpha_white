# frozen_string_literal: true

FactoryBot.define do
  factory :enem_exam do
    year { 2023 }
    day { "D1" }
    sequence(:booklet_color) { |n| "CD#{n}" }

    trait :d2 do
      day { "D2" }
    end
  end
end
