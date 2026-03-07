require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe '#create' do
    it 'can create new profile' do
      create(:profile)
    end
  describe 'associations' do
      it { is_expected.to belong_to(:user) }
  end
  end
end
