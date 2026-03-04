require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe 'devise' do
    it 'new registration' do
      visit(new_user_registration_path)
      fill_in "Name", with: "hello"
      fill_in "Email", with: "hello123@gmail.com"
      fill_in "Password", with: "hello123"
      fill_in "Password confirmation", with: "hello123"
      click_on "Sign up"
      expect(page).to have_content('Forgot your password?')
    end
  end
end
