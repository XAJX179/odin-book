class PostComment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "PostComment", optional: true
  has_many :replies, class_name: "PostComment", inverse_of: "parent_id", dependent: :destroy
end
