require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe '#create' do
    it 'can create new friendship' do
      create(:friendship)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:friend) }
  end
end
