require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#create' do
    it 'can create new post' do
      create(:post)
    end
  end
end
