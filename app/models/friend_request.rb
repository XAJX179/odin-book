class FriendRequest < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  enum :status, { pending: 0, accepted: 1, ignored: 2 }

  after_destroy_commit do
    broadcast_remove_to "friend-requests-#{to_id}"
    broadcast_remove_to "friend-requests-#{from_id}"
  end
  after_create_commit do
    broadcast_prepend_to "friend-requests-#{to_id}", target: "friend-requests", locals: { user_id: to_id }
    broadcast_prepend_to "friend-requests-#{from_id}", target: "friend-requests", locals: { user_id: from_id }
  end
  after_update_commit do
    broadcast_replace_to "friend-requests-#{to_id}", target: "friend_request_#{id}", locals: { user_id: to_id }
    broadcast_replace_to "friend-requests-#{from_id}", target: "friend_request_#{id}", locals: { user_id: from_id }
  end

  validates :status, presence: true

  LIMIT = 10

  def self.load_incoming_by_user(user, set_offset, set_limit = LIMIT)
    includes(:to, :from).where(to: user.id).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.load_outgoing_by_user(user, set_offset, set_limit = LIMIT)
    includes(:to, :from).where(from: user.id).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.between(user1, user2)
    where(to: user1, from: user2).or(FriendRequest.where(to: user2, from: user1))
  end

  def opposite_request
    FriendRequest.find_by(to: from, from: to)
  end
end
