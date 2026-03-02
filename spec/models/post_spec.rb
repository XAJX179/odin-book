require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#create' do
    it 'can create new post' do
      create(:post)
    end
  end
  describe 'associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to have_many(:post_likes) }
    it { is_expected.to have_many(:post_comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it {
      is_expected.to validate_length_of(:title)
        .is_at_least(10).is_at_most(100)
    }
    it {
      is_expected.to validate_length_of(:body)
        .is_at_least(20).is_at_most(900)
    }
  end
end
