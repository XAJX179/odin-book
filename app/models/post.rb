class Post < ApplicationRecord
  include ActionTextValidator

  belongs_to :author, class_name: "User"
  has_many :post_likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_rich_text :body

  after_create_commit do
    broadcast_prepend_to "all-posts", target: "posts"
    current_user_id = author.id
    user_ids = author.friend_ids
    user_ids << current_user_id
    user_ids.each do |user_id|
      broadcast_prepend_to "feed-posts-for-#{user_id}", target: "posts"
    end
  end
  after_update_commit do
    broadcast_replace_to "all-posts", target: "post_#{id}"
    current_user_id = author.id
    follower_user_ids = author.friend_ids
    follower_user_ids << current_user_id
    follower_user_ids.each do |user_id|
      broadcast_replace_to "feed-posts-for-#{user_id}", target: "post_#{id}"
    end
  end
  after_destroy_commit do
    broadcast_remove_to "all-posts", target: "post_#{id}"
    current_user_id = author.id
    follower_user_ids = author.friend_ids
    follower_user_ids << current_user_id
    follower_user_ids.each do |user_id|
      broadcast_remove_to "feed-posts-for-#{user_id}", target: "post_#{id}"
    end
  end

  validates :title, presence: true, length: { within: 10..100 }
  validate :has_rich_text_content

  LIMIT = 5

  def self.load_all(set_offset, set_limit = LIMIT)
    includes(:author, :post_likes, :post_comments).order(created_at: :desc).limit(set_limit).offset(set_offset)
                                                  .with_rich_text_body_and_embeds
  end

  def self.load_feed(user, set_offset, set_limit = LIMIT)
    includes(:author, :post_likes, :post_comments).where(author: (user.friend_ids << user.id))
                                                  .order(created_at: :desc).limit(set_limit).offset(set_offset)
                                                  .with_rich_text_body_and_embeds
  end

  def self.load_by_user(user, set_offset, set_limit = LIMIT)
    includes(:author, :post_likes, :post_comments).where(author: user.id)
                                                  .order(created_at: :desc).limit(set_limit).offset(set_offset)
                                                  .with_rich_text_body_and_embeds
  end

  def self.show(id)
    includes(:author, :post_likes, post_comments: %i[author rich_text_body]).where(id: id)
                                                                            .with_rich_text_body_and_embeds.first
  end
end
