require 'rails_helper'

RSpec.describe "Likes", type: :request do
  describe "#create" do
    it "returns http success and sends turbo_stream" do
      user = create(:user)
      sign_in user
      post = create(:post, author: user)
      post post_likes_url(post, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "update", target: "post-like-button")
    end
    it "increases like count" do
      user = create(:user)
      sign_in user
      post = create(:post, author: user)
      post post_likes_url(post, format: "turbo_stream")
      post.reload
      expect(post.post_likes.size).to eq(1)
    end
  end

  describe "#destroy" do
    it "returns http success and sends turbo_stream" do
      user = create(:user)
      sign_in user
      post = create(:post, author: user)
      post post_likes_url(post, format: "turbo_stream")
      post.reload
      like = post.post_likes.first
      delete post_like_url(post_id: post, id: like, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "update", target: "post-like-button")
    end

    it "decreases like count" do
      user = create(:user)
      sign_in user
      post = create(:post, author: user)
      post post_likes_url(post, format: "turbo_stream")
      post.reload
      like = post.post_likes.first
      delete post_like_url(post_id: post, id: like, format: "turbo_stream")
      expect(post.post_likes.size).to eq(0)
    end
  end
end
