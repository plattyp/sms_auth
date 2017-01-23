FactoryGirl.define do
  factory :authentication_token do
    body { Faker::Code.ean }
    deleted_at nil
    expired_at { Time.zone.today + 3.months }
    association :user, factory: :user
  end

  trait :without_body do
    body nil
  end
end
