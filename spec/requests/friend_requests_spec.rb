require 'rails_helper'

RSpec.describe "FriendRequests", type: :request do
  describe "GET /index" do
    it "returns http success and renders index" do
      user = create(:user)
      sign_in user
      get friend_requests_url
      expect(response).to have_http_status(:success).and render_template(:index)
    end
  end

  describe "GET /create" do
    it "returns http success and renders cancel button" do
      user = create(:user)
      user1 = create(:user)
      sign_in user
      post friend_requests_url(friend_request: { to: user1.name })
      expect(response).to have_http_status(:success).and render_template("_cancel_button")
    end
  end

  describe "GET /new" do
    it "returns http success and renders new form" do
      user = create(:user)
      sign_in user
      get new_friend_request_url
      expect(response).to have_http_status(:success).and render_template(:new)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      user = create(:user)
      user1 = create(:user)
      sign_in user
      post friend_requests_url(friend_request: { to: user1.name })
      delete friend_request_url(id: user.outgoing_friend_request_ids.first)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /incoming" do
    it "returns http success and renders incoming" do
      user = create(:user)
      sign_in user
      get incoming_friend_requests_url
      expect(response).to have_http_status(:success).and render_template(:incoming)
    end
  end

  describe "GET /outgoing" do
    it "returns http success and renders outgoing" do
      user = create(:user)
      sign_in user
      get outgoing_friend_requests_url
      expect(response).to have_http_status(:success).and render_template(:outgoing)
    end
  end

  describe "GET /load_incoming" do
    it "returns http success and renders incoming" do
      user = create(:user)
      user1 = create(:user)
      sign_in user1
      post friend_requests_url(friend_request: { to: user.name })
      sign_in user
      get load_incoming_friend_requests_url(format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "before", target: "friend-requests-loader")
      assert_turbo_stream(action: "replace", target: "friend-requests-loader")
    end
    it "returns http success and renders remove loader" do
      user = create(:user)
      sign_in user
      get load_incoming_friend_requests_url(format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "replace", target: "friend-requests-loader")
    end
  end

  describe "GET /load_outgoing" do
    it "returns http success and renders incoming" do
      user = create(:user)
      user1 = create(:user)
      sign_in user
      post friend_requests_url(friend_request: { to: user1.name })
      get load_outgoing_friend_requests_url(format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "before", target: "friend-requests-loader")
      assert_turbo_stream(action: "replace", target: "friend-requests-loader")
    end
    it "returns http success and renders remove loader" do
      user = create(:user)
      sign_in user
      get load_outgoing_friend_requests_url(format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "replace", target: "friend-requests-loader")
    end
  end

  describe "accept" do
    it "returns http success" do
      user = create(:user)
      user1 = create(:user)
      sign_in user
      post friend_requests_url(friend_request: { to: user1.name })
      sign_in user1
      post accept_friend_request_url(id: user1.incoming_friend_request_ids.first)
      expect(response).to have_http_status(:success)
    end
  end
end
