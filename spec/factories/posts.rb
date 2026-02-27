FactoryBot.define do
  factory :post do
    sequence(:title, -> { Post.count + 1 }) { |n| "post_title_#{n}" }
    sequence(:body, -> { Post.count + 1 }) { |n| "post_body_#{n}_by_#{author.name}" }
    author
  end
end
