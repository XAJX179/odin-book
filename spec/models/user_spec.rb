require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create' do
    it 'can create new user' do
      create(:user)
    end
  end
end
