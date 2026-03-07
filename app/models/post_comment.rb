class PostComment < ApplicationRecord
  include ActionTextValidator

  belongs_to :author, class_name: "User"
  belongs_to :post
  belongs_to :parent, class_name: "PostComment", optional: true
  has_many :replies, class_name: "PostComment", inverse_of: :parent, dependent: :destroy
  has_rich_text :body

  validate :has_rich_text_content
end
