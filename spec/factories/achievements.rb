FactoryBot.define do
  factory :achievement do
    sequence(:slug) { |n| "achievement_#{n}" }
    name { "Conquista de teste" }
    description { "Descrição da conquista." }
    kind { :event }
    threshold { 1 }
  end
end
