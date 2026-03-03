require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create' do
    it 'can create new user' do
      create(:user)
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:friendships) }
    it { is_expected.to have_many(:friends) }
    it { is_expected.to have_many(:incoming_friend_requests) }
    it { is_expected.to have_many(:outgoing_friend_requests) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:post_likes) }
    it { is_expected.to have_many(:post_comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_confirmation_of(:password) }
    it {
      is_expected.to validate_length_of(:name)
        .is_at_least(3).is_at_most(25)
    }
    it {
          is_expected.to validate_length_of(:password)
            .is_at_least(8).is_at_most(100)
    }
  end
end
