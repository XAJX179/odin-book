class FriendRequest < ApplicationRecord
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"
  enum :status, { pending: 0, accepted: 1, ignored: 2 }

  after_destroy_commit do
    broadcast_remove_to "incoming-friend-requests-#{to_id}"
    broadcast_remove_to "outgoing-friend-requests-#{from_id}"
    unless friends?
      broadcast_replace_to "profile_#{to_id}_viewer_#{from_id}",
                           target: "user_#{to_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: to }
      broadcast_replace_to "profile_#{from_id}_viewer_#{to_id}",
                           target: "user_#{from_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: from }
      broadcast_replace_to "users_viewer_#{to_id}",
                           target: "user_#{from_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: from }
      broadcast_replace_to "users_viewer_#{to_id}",
                           target: "search_result_user_#{from_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: from, search_result: true }
      broadcast_replace_to "users_viewer_#{from_id}",
                           target: "user_#{to_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: to }
      broadcast_replace_to "users_viewer_#{from_id}",
                           target: "search_result_user_#{to_id}_profile_action_button",
                           partial: "friend_requests/send_button", locals: { user: to, search_result: true }
    end
  end
  after_create_commit do
    broadcast_prepend_to "incoming-friend-requests-#{to_id}",
                         target: "friend-requests", locals: { user_id: to_id }
    broadcast_prepend_to "outgoing-friend-requests-#{from_id}",
                         target: "friend-requests", locals: { user_id: from_id }
      broadcast_replace_to "users_viewer_#{to_id}",
                           target: "user_#{from_id}_profile_action_button",
                           partial: "friend_requests/cancel_button", locals: { user: from }
      broadcast_replace_to "users_viewer_#{to_id}",
                           target: "search_result_user_#{from_id}_profile_action_button",
                           partial: "friend_requests/cancel_button", locals: { user: from, search_result: true }
      broadcast_replace_to "users_viewer_#{from_id}",
                           target: "user_#{to_id}_profile_action_button",
                           partial: "friend_requests/cancel_button", locals: { user: to }
      broadcast_replace_to "users_viewer_#{from_id}",
                           target: "search_result_user_#{to_id}_profile_action_button",
                           partial: "friend_requests/cancel_button", locals: { user: to, search_result: true }
  end
  after_update_commit do
    broadcast_replace_to "incoming-friend-requests-#{to_id}",
                         target: "friend_request_#{id}", locals: { user_id: to_id }
    broadcast_replace_to "outgoing-friend-requests-#{from_id}",
                         target: "friend_request_#{id}", locals: { user_id: from_id }
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

  private

  def friends?
    to.friends.include? from
  end
end
