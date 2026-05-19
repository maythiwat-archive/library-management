FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end

  trait :with_member_profile do
    after(:create) do |user|
      create(:member_profile, user: user)
    end
  end
end
