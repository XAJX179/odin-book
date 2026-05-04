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
      broadcast_append_to "post_#{post.id}", target: "post_comment_#{parent_id}", partial: "comments/show_reply_button", locals: { comment: parent } if parent.replies.size == 1
    end
  end

  after_update_commit do
    broadcast_replace_to "post_#{post.id}", target: "post_comment_#{id}", partial: "comments/comment", locals: { comment: self }
  end

  after_destroy_commit do
    broadcast_remove_to "post_#{post.id}", target: "post_comment_#{id}"
  end

  validate :has_rich_text_content

  LIMIT = 1

  def self.show(id)
    includes(:author).where(id: id).with_rich_text_body_and_embeds.first
  end

  def self.load(post, parent, set_offset, set_limit = LIMIT)
      where(parent: parent, post: post)
        .includes(:author)
        .order(created_at: :desc).limit(set_limit).offset(set_offset)
        .with_rich_text_body_and_embeds
  end

  def deep?(current_parent = parent, parents_count = 0, new_tlc: nil)
    if new_tlc.nil?
      return false if current_parent.nil?
      return true if parents_count >= 3

      deep?(current_parent.parent, parents_count + 1)
    else
      return false if current_parent.nil? || id.to_s == new_tlc
      return true if parents_count >= 3 && current_parent.id.to_s == new_tlc
      return false if parents_count >= 4

      deep?(current_parent.parent, parents_count + 1, new_tlc: new_tlc)
    end
  end
end
