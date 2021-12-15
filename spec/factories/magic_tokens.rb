FactoryBot.define do
  factory :magic_token, class: 'MagicLinks::MagicToken' do
    target_path { '/bookings/123' }
    action_scope { {booking: :show} }
    association :magic_token_authenticatable, factory: :user
  end
end
