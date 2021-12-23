FactoryBot.define do
  factory :booking do
    association(:user)
    work_description { 'My car will not start.' }
  end
end
