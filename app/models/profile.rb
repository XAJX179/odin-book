class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar

  validate :validate_avatar

  private

  def validate_avatar
    return unless avatar.attached?

    acceptable_types = %w[image/png image/jpeg image/gif image/webp]
    errors.add(:avatar, "must be a valid image format") unless acceptable_types.include?(avatar.content_type)

    errors.add(:avatar, "must be less than 1MB") if avatar.byte_size > 1.megabyte
  end
end
