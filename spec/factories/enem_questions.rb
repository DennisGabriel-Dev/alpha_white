# frozen_string_literal: true

FactoryBot.define do
  factory :enem_question do
    association :enem_exam
    sequence(:number_in_exam)
    area { "LC" }
    skill { nil }
    statement { Faker::Lorem.paragraph }
    alternatives do
      [
        { "letter" => "A", "text" => Faker::Lorem.sentence },
        { "letter" => "B", "text" => Faker::Lorem.sentence }
      ]
    end
    correct_letter { "A" }
  end
end
