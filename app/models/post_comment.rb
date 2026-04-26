class PostComment < ApplicationRecord
  include ActionTextValidator

  belongs_to :author, class_name: "User"
  belongs_to :post
  belongs_to :parent, class_name: "PostComment", optional: true
  has_many :replies, class_name: "PostComment", inverse_of: :parent, dependent: :destroy
  has_rich_text :body

  after_create_commit do
    if parent.nil?
      broadcast_prepend_to "post_#{post.id}", target: "comments", partial: "comments/comment", locals: { comment: self }
    else
      broadcast_prepend_to "post_#{post.id}", target: "replies_to_post_comment_#{parent_id}", partial: "comments/comment", locals: { comment: self }
    end
  end

  after_update_commit do
    broadcast_replace_to "post_#{post.id}", target: "post_comment_#{id}", partial: "comments/comment", locals: { comment: self }
  end

  after_destroy_commit do
    broadcast_remove_to "post_#{post.id}", target: "post_comment_#{id}"
  end

  validate :has_rich_text_content

  def self.show(id)
    includes(:author).where(id: id).with_rich_text_body_and_embeds.first
  end

  def self.top_level(post)
      where(parent: nil, post: post)
        .includes(:author)
        .order(created_at: :desc).limit(10)
        .with_rich_text_body_and_embeds
  end
end
