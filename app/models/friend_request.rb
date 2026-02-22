class FriendRequest < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  enum :status, { pending: 0, accepted: 1, ignored: 2 }
end
