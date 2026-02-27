FactoryBot.define do
  factory :post_comment do
    author
    post
    parent { association :post_comment, parent: nil }
    sequence(:body, -> { PostComment.count + 1 }) { |n| "post_comment_#{n}_by_#{author.name}" }
  end
end
