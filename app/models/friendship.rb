class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  after_create_commit do
    broadcast_refresh_to "friends-#{user_id}"
    broadcast_replace_to "feed-posts-for-#{user_id}", target: "posts", template: "posts/feed", locals: { current_user: user }
    broadcast_replace_to "feed-posts-for-#{friend_id}", target: "posts", template: "posts/feed", locals: { current_user: friend }
    broadcast_replace_to "profile_#{friend_id}_viewer_#{user_id}", target: "profile_action_button", partial: "friends/remove_button", locals: { current_user: user, user: friend }
  end

  after_destroy_commit do
    broadcast_remove_to "friends-#{user_id}", target: "user_#{friend_id}"
    broadcast_replace_to "feed-posts-for-#{user_id}", target: "posts", template: "posts/feed", locals: { current_user: user }
    broadcast_replace_to "feed-posts-for-#{friend_id}", target: "posts", template: "posts/feed", locals: { current_user: friend }
    broadcast_replace_to "profile_#{friend_id}_viewer_#{user_id}", target: "profile_action_button", partial: "friend_requests/send_button", locals: { user: friend }
  end

  LIMIT = 10

  def self.delete_for(user_id, friend_id)
    Friendship.find_by(user_id: user_id, friend_id: friend_id).destroy
    Friendship.find_by(user_id: friend_id, friend_id: user_id).destroy
  end
end
