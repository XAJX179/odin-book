class Post < ApplicationRecord
  include ActionTextValidator

  belongs_to :author, class_name: "User"
  has_many :post_likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_rich_text :body

  validates :title, presence: true, length: { within: 10..100 }
  validate :has_rich_text_content

  LIMIT = 5

  def self.load_all(set_offset, set_limit = LIMIT)
    includes(:author).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.load_feed(user, set_offset, set_limit = LIMIT)
    includes(:author).where(author: (user.friend_ids << user.id)).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.load_by_user(user, set_offset, set_limit = LIMIT)
    includes(:author).where(author: (user.id)).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end
end
