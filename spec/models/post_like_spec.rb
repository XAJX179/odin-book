require 'rails_helper'

RSpec.describe PostLike, type: :model do
  describe '#create' do
    it 'can create new post like' do
      create(:post_like)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:post) }
  end
end
