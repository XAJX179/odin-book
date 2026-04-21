class PostLike < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: "User"

  after_create_commit do
    broadcast_update_to "post_#{post.id}", target: "post-likes", locals: { post: post }
  end

  after_destroy_commit do
    broadcast_update_to "post_#{post.id}", target: "post-likes", locals: { post: post }
  end
end
