FactoryBot.define do
  factory :enem_import_job do
    association :user
    tenant { user.tenant }
    status { :pending }
  end
end
