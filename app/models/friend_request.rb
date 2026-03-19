class FriendRequest < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  enum :status, { pending: 0, accepted: 1, ignored: 2 }

  validates :status, presence: true

  LIMIT = 10

  def self.load_incoming_by_user(user, set_offset, set_limit = LIMIT)
    includes(:to).where(to: user.id).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.load_outgoing_by_user(user, set_offset, set_limit = LIMIT)
    includes(:to).where(from: user.id).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end
end
