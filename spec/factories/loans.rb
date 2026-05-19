FactoryBot.define do
  factory :loan do
    association :book
    association :user
    loaned_at { Time.current }
    due_at { 1.week.from_now }
  end
end
