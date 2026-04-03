module ActionTextValidator
  extend ActiveSupport::Concern

  ALLOWED_TYPES = %w[
    image/png
    image/jpeg
    image/gif
    image/webp
    video/mp4
    video/webm
  ].freeze

  included do
    def has_rich_text_content # rubocop:disable Naming/PredicatePrefix
      errors.add(:base, "Body too short (minimum length: 20)") if body&.body&.to_plain_text.to_s.length < 20

      return if body&.body&.attachments.blank?

      size = 0
      body.body.attachments.each do |attach|
        return errors.add(:base, "Only images and videos are allowed. (png,jpeg,gif,webp,mp4,webm)") unless ALLOWED_TYPES.include?(attach.content_type)

        errors.add(:base, "File is too large. only files less than 2mb allowed.") if attach.byte_size > 2.megabytes

        size += attach.byte_size
      end

      errors.add(:base, "Total size of files are large. Only 2mb max for all files.") if size > 2.megabytes
    end
  end
end
