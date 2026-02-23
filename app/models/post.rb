class Post < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_many :post_likes, dependent: :destroy
  has_many :post_comments, dependent: :destroy
end
