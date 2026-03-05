# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Posts", type: :request do
  context "GET / with signed in user" do
    it "returns http moved_permanently and redirects to posts" do
      user = create(:user)
      sign_in user
      get "/"
      expect(response).to have_http_status(:moved_permanently).and redirect_to('/posts')
    end

    it "returns remove loader stream if no posts available!" do
      user = create(:user)
      sign_in user
      get "/load_posts.turbo_stream"
      expect(response).to have_http_status(:ok)
      assert_turbo_stream(action: "replace", target: "posts-loader")
    end

    it "returns load post stream and replace loader with new offset if posts available!" do
      8.times { create(:post) }
      user = create(:user)
      sign_in user
      get "/load_posts.turbo_stream"
      expect(response).to have_http_status(:ok)
      assert_turbo_stream(action: "append", target: "posts")
      assert_turbo_stream(action: "replace", target: "posts-loader")
    end
  end

  context "GET / without signed in user" do
    it "returns http ok, redirecting to login page" do
      get "/"
      expect(response).to have_http_status(:ok).and render_template('devise/sessions/new')
    end
  end
end
