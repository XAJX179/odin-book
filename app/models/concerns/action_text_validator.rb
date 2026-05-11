module ActionTextValidator
  extend ActiveSupport::Concern

  ALLOWED_TYPES = %w[
    image/png
    image/jpeg
    image/gif
    image/webp
  ].freeze

  included do
    def has_rich_text_content # rubocop:disable Naming/PredicatePrefix
      errors.add(:base, "Body too short (minimum length: 20)") if body&.body&.to_plain_text.to_s.length < 20

      return if body&.body&.attachments.blank?

      size = 0
      body.body.attachments.each do |attach|
        return errors.add(:base, "Only images are allowed, in the following formats: [png,jpeg,gif,webp]. For videos you can link a youtube video!") unless ALLOWED_TYPES.include?(attach.content_type)

        errors.add(:base, "Image is too large. only image less than 300kb allowed. compress it or share a link!") if attach.byte_size > 300.kilobytes

        size += attach.byte_size
      end

      errors.add(:base, "Only 300kb max for all images in one post or comment. share links instead!") if size > 300.kilobytes
    end
  end
end
