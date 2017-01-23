FactoryGirl.define do
  factory :phone_verification do
    phone_number { Faker::PhoneNumber.phone_number }
    verification_token '123456'
    verified_at '2016-05-28 10:46:46'
    expired_at '2016-05-28 10:46:46'
    unlocked_at nil
    login_attempts []
    association :user, factory: :user
  end
end
