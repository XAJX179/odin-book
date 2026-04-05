class User < ApplicationRecord
  require "open-uri"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: %i[github discord]

  attr_writer :login

  normalizes :name, with: ->(name) { name.strip.downcase.delete("^a-zA-Z0-9_") }
  normalizes :email, with: ->(email) { email.strip.downcase }

  def login
    @login || name || email
  end

  def self.from_omniauth(auth)
    user = find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = if auth.provider == "github"
                    auth.info.nickname + "_from_#{auth.provider}"
      else
                    auth.extra.raw_info.username + "_from_#{auth.provider}"
      end
      user.skip_confirmation!
    end
    user.profile ||= user.build_profile
    user.profile.display_name = auth.provider == "github" ? auth.info.name : auth.extra.raw_info.global_name
    attach_profile_avatar(user, auth)
    user
  end

  def self.avatar_image_url(auth)
    size_query = if auth.provider == "discord"
                   "?size=256"
    else
                   "&size=256"
    end
    auth.info.image + size_query
  end

  def self.attach_profile_avatar(user, auth)
      file = URI.parse(avatar_image_url(auth)).open
      user.profile.avatar.attach(
        io: file,
        filename: "avatar-#{user.id}.png",
        content_type: file.content_type
      )

      user.profile.save!
  rescue StandardError => e
      Rails.logger.error "Avatar download/attach failed: #{e.message}"
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([ "lower(name) = :value OR lower(email) = :value", { value: login.downcase } ]).first
    elsif conditions.key?(:name) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :incoming_friend_requests, class_name: "FriendRequest", dependent: :destroy, inverse_of: :to
  has_many :outgoing_friend_requests, class_name: "FriendRequest", dependent: :destroy, inverse_of: :from
  has_many :posts, dependent: :destroy, inverse_of: :author
  has_many :post_likes, dependent: :destroy, inverse_of: :author
  has_many :post_comments, dependent: :destroy, inverse_of: :author
  has_one  :profile, dependent: :destroy

  after_create_commit do
    broadcast_prepend_to "users"
  end

  validates :name, presence: true, length: { within: 3..25 }, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9_.-]+\z/ }
  validates :password, presence: true, length: { within: 8..100 }

  after_create :add_profile

  LIMIT = 5

  def self.load_all(set_offset, set_limit = LIMIT)
    includes(profile: { avatar_attachment: :blob }).order(created_at: :desc).limit(set_limit).offset(set_offset)
  end

  def self.search(name)
    where("name ILIKE ?", "%#{User.sanitize_sql_like(name)}%")
      .includes(profile: { avatar_attachment: :blob }).order(created_at: :desc).limit(10)
  end

  def add_profile
    create_profile(display_name: name, about: "...")
  end
end
