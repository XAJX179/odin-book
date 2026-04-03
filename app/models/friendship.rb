class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  after_create_commit do
    broadcast_refresh_to "friends-#{user_id}"
  end

  after_destroy_commit do
    broadcast_remove_to "friends-#{user_id}", target: "user_#{friend_id}"
  end

  LIMIT = 10

  def self.delete_for(user_id, friend_id)
    Friendship.find_by(user_id: user_id, friend_id: friend_id).destroy
    Friendship.find_by(user_id: friend_id, friend_id: user_id).destroy
  end
end
