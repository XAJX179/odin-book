class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :post_likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy

  validates :title, presence: true, length: { within: 10..100 }
  validates :body, presence: true, length: { within: 20..900 }

  LIMIT = 5

  def self.load_posts(set_offset, set_limit = LIMIT)
    includes(:author).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.load_user_feed_posts(user, set_offset, set_limit = LIMIT)
    includes(:author).where(author: (user.friend_ids << user.id)).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end
end
