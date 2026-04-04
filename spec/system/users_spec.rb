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
      expect(page).to have_content('A message with a confirmation link has been sent to your email address.')
    end

    it 'login user' do
      visit(new_user_session_path)
      u = create(:user)
      fill_in "Login", with: u.name
      fill_in "Password", with: "abcdef!@123"
      click_on "Log in"
      expect(page).to have_content('Feed')
    end
  end
end
