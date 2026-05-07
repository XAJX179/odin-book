require 'rails_helper'

RSpec.describe "Comments", type: :request do
  describe "GET /index" do
    it "returns http success and renders index" do
      user = create(:user)
      post = create(:post)
      sign_in user
      get post_comments_url(post)
      expect(response).to have_http_status(:success).and render_template(:index)
    end
  end

  describe "GET /new" do
    it "returns http success and renders new form" do
      user = create(:user)
      post = create(:post)
      sign_in user
      get new_post_comment_url(post)
      expect(response).to have_http_status(:success).and render_template(:new)
    end
  end

  describe "POST /create" do
    it "returns http success and renders cancel button" do
      user = create(:user)
      post = create(:post)
      sign_in user
      post post_comments_url(post, post_comment: { post_id: post.id, body: "helllooooooooooooo my frnd", parent_id: "" }, format: "turbo_stream")
      expect(response).to have_http_status(:success).and render_template("create")
    end
  end

  describe "GET /show" do
    it "returns http success and renders show" do
      user = create(:user)
      comment = create(:post_comment)
      sign_in user
      get post_comment_url(comment.post, comment)
      expect(response).to have_http_status(:success).and render_template("show")
    end
  end

  describe "GET /edit" do
    it "returns http success and renders edit" do
      user = create(:user)
      comment = create(:post_comment)
      sign_in user
      get edit_post_comment_url(comment.post, comment)
      expect(response).to have_http_status(:success).and render_template("edit")
    end
  end

  describe "PATCH /update" do
    it "returns http success" do
      user = create(:user)
      comment = create(:post_comment)
      sign_in user
      patch post_comment_url(comment.post, comment, post_comment: { post_id: comment.post.id, body: "helllooooooooooooo my frnd", parent_id: "" })
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      user = create(:user)
      comment = create(:post_comment, author: user)
      sign_in user
      delete post_comment_url(comment.post, comment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /buttons" do
    it "returns http success and renders buttons" do
      user = create(:user)
      comment = create(:post_comment)
      sign_in user
      get buttons_post_comment_url(comment.post, comment)
      expect(response).to have_http_status(:success).and render_template("buttons")
    end
  end

  describe "GET /load" do
    it "returns http success and loads comments" do
      user = create(:user)
      post = create(:post)
      create(:post_comment, post: post, parent: nil)
      create(:post_comment, post: post, parent: nil)
      create(:post_comment, post: post, parent: nil)
      sign_in user
      get load_post_comments_url(post, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "before", target: "comments-loader")
      assert_turbo_stream(action: "replace", target: "comments-loader")
    end
  end

  describe "GET /replies" do
    it "returns http success and loads replies" do
      user = create(:user)
      post = create(:post)
      first = create(:post_comment, post: post, parent: nil)
      create(:post_comment, post: post, parent: first)
      create(:post_comment, post: post, parent: first)
      sign_in user
      get replies_to_post_comment_url(post, first, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "append", target: dom_id(first))
      assert_turbo_stream(action: "replace", target: dom_id(first, :replies_toggle))
    end
  end

  describe "GET /load_replies" do
    it "returns http success and loads replies" do
      user = create(:user)
      post = create(:post)
      first = create(:post_comment, post: post, parent: nil)
      create(:post_comment, post: post, parent: first)
      create(:post_comment, post: post, parent: first)
      sign_in user
      get load_replies_to_post_comment_url(post, first, format: "turbo_stream")
      expect(response).to have_http_status(:success)
      assert_turbo_stream(action: "before", target: "#{first.id}-replies-loader")
      assert_turbo_stream(action: "replace", target: "#{first.id}-replies-loader")
    end
  end
end
