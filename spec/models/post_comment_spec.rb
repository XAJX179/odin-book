require 'rails_helper'

RSpec.describe PostComment, type: :model do
  describe '#create' do
    it 'can create new post comment' do
      create(:post_comment)
    end
  end
end
