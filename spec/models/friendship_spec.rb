require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe '#create' do
    it 'can create new friendship' do
      create(:friendship)
    end
  end
end
