FactoryBot.define do
  factory :post do
    sequence(:title, -> { Post.count + 1 }) { |n| "post_title_#{n}" }
    body { "Hello world body content" }
    author
  end
end
