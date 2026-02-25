class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :post_likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy

  LIMIT = 5

  def self.load_posts(set_offset, set_limit = LIMIT)
    includes(:author).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end
end
