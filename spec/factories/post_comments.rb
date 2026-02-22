FactoryBot.define do
  factory :post_comment do
    user { nil }
    post { nil }
    parent { nil }
  end
end
