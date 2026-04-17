require 'rails_helper'

RSpec.describe "Friends", type: :request do
  describe "GET /index" do
    it "returns http success" do
      user = create(:user)
      sign_in user
      get user_friends_url(user)
      expect(response).to have_http_status(:success).and render_template("friends/index")
    end
  end

  describe '#load_for_user' do
    it "returns http success and sends remove loader turbo_stream when friends empty" do
      user = create(:user)
      sign_in user
      get load_friends_for_user_url(user, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "replace", target: "friends-loader") do
        assert_select "template p", text: /End/
      end
    end
    it "returns http success and sends friends loader turbo_stream when friends exists" do
          user = create(:user)
          user1 = create(:user)
          create(:friendship, user: user, friend: user1)
          create(:friendship, user: user1, friend: user)
          sign_in user
          get load_friends_for_user_url(user, format: "turbo_stream")
          expect(response).to have_http_status(:success)
          assert_turbo_stream(action: "replace", target: "friends-loader")
          assert_turbo_stream(action: "before", target: "friends-loader")
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      user = create(:user)
      user1 = create(:user)
      create(:friendship, user: user, friend: user1)
      create(:friendship, user: user1, friend: user)
      sign_in user
      delete user_friend_url(user, user1)
      expect(response).to have_http_status(:success).and render_template("friend_requests/_send_button")
    end
  end
end
