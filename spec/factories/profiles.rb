FactoryBot.define do
  factory :profile do
    user
    sequence(:display_name, -> { User.count + 1 }) { |n| "user_display_name_#{n}" }
    sequence(:about, -> { User.count + 1 }) { |n| "user_about_text_#{n}" }
  end
end
