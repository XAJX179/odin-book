FactoryBot.define do
  factory :user, aliases: %i[author friend from to] do
    after :create, &:confirm
    sequence(:email, -> { User.count + 1 }) { |n| "user_email_#{n}@example.com" }
    sequence(:name, -> { User.count + 1 }) { |n| "user_name_#{n}" }
    password { 'abcdef!@123' }
  end
end
