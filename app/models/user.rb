class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: %i[github discord]

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.skip_confirmation!
    end
  end

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :incoming_friend_requests, class_name: "FriendRequest", dependent: :destroy, inverse_of: :to
  has_many :outgoing_friend_requests, class_name: "FriendRequest", dependent: :destroy, inverse_of: :from
  has_many :posts, dependent: :destroy
  has_many :post_likes, dependent: :destroy
end
