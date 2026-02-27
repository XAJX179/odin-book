require 'rails_helper'

RSpec.describe FriendRequest, type: :model do
  describe '#create' do
    it 'can create new friend request' do
      create(:friend_request)
    end
  end
end
