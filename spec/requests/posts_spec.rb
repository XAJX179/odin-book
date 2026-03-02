# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Posts", type: :request do
  context "GET / with signed in user" do
    it "returns http ok and render index" do
      user = create(:user)
      sign_in user
      get "/"
      expect(response).to have_http_status(:ok).and render_template(:index)
    end

    it "returns remove loader stream if no posts available!" do
          user = create(:user)
          sign_in user
          get "/load_posts.turbo_stream"
          expect(response).to have_http_status(:ok)
          assert_turbo_stream(action: "replace", target: "posts-loader")
    end
  end

  context "GET / without signed in user" do
    it "returns http found, redirecting to login page" do
      get "/"
      expect(response).to have_http_status(:found).and redirect_to(new_user_session_url)
    end
  end
end
