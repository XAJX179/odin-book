require 'rails_helper'

RSpec.describe "FriendRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/friend_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/friend_requests/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/friend_requests/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/friend_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/friend_requests/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /incoming" do
    it "returns http success" do
      get "/friend_requests/incoming"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /outgoing" do
    it "returns http success" do
      get "/friend_requests/outgoing"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /load_incoming" do
    it "returns http success" do
      get "/friend_requests/load_incoming"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /load_outgoing" do
    it "returns http success" do
      get "/friend_requests/load_outgoing"
      expect(response).to have_http_status(:success)
    end
  end
end
