FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
  end
end
