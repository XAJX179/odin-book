require 'rails_helper'

RSpec.describe PostComment, type: :model do
  subject { create(:post_comment) }
  describe '#create' do
    it 'can create new post comment' do
      create(:post_comment)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:parent).optional }
    it {
      is_expected.to have_many(:replies).class_name("PostComment").inverse_of('parent').dependent(:destroy)
    }
  end

  describe 'validations' do # rubocop:disable Lint/EmptyBlock
  end
end
