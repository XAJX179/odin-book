require 'rails_helper'

RSpec.describe FriendRequest, type: :model do
  describe '#create' do
    it 'can create new friend request' do
      create(:friend_request)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:to) }
    it { is_expected.to belong_to(:from) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
  end
end
