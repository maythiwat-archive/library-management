FactoryBot.define do
  factory :book do
    name { "Sample Book" }
    association :author
  end
end
