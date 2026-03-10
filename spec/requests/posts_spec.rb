# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Posts", type: :request do
  context "with signed in user" do
    describe '#index' do
      it "returns http moved_permanently and redirects to posts" do
        user = create(:user)
        sign_in user
        get "/"
        expect(response).to have_http_status(:moved_permanently).and redirect_to(posts_url)
      end

      it "returns remove loader stream if no posts available!" do
        user = create(:user)
        sign_in user
        get "/posts/load_posts.turbo_stream"
        expect(response).to have_http_status(:ok)
        assert_turbo_stream(action: "replace", target: "posts-loader")
      end

      it "returns load post stream and replace loader with new offset if posts available!" do
        8.times { create(:post) }
        user = create(:user)
        sign_in user
        get "/posts/load_posts.turbo_stream"
        expect(response).to have_http_status(:ok)
        assert_turbo_stream(action: "append", target: "posts")
        assert_turbo_stream(action: "replace", target: "posts-loader")
      end
    end
    describe '#show' do
      it 'render index when post not found' do
        user = create(:user)
        sign_in user
        get post_url(99_999)
        expect(response).to have_http_status(:not_found).and render_template(:index)
      end
      it 'render show when post found' do
        user = create(:user)
        sign_in user
        post = create(:post)
        get post_url(post)
        expect(response).to have_http_status(:ok).and render_template(:show)
      end
    end
    describe '#new' do
      it "returns new post form" do
        user = create(:user)
        sign_in user
        get new_post_url
        expect(response).to have_http_status(:ok).and render_template(:new)
      end
    end
    describe '#create' do
      it "creates post if valid params" do
        user = create(:user)
        sign_in user
        attr = attributes_for(:post, author: user)
        post posts_url, params: { post: { title: attr[:title], body: attr[:body] } }
        expect(response).to have_http_status(:see_other).and redirect_to(posts_url)
      end
      it "could not create if invalid params " do
        user = create(:user)
        sign_in user
        post posts_url, params: { post: { title: "", body: "" } }
        expect(response).to have_http_status(:unprocessable_content).and render_template(:new)
      end
    end
    describe '#edit' do
      it "render show if post does not belong to current user" do
        user = create(:user)
        sign_in user
        post = create(:post)
        get edit_post_url(post)
        expect(response).to have_http_status(:forbidden).and render_template(:show)
      end
      it "render edit form if post belongs to current user" do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        get edit_post_url(post)
        expect(response).to have_http_status(:ok).and render_template(:edit)
      end
      it "render index if post not found" do
        user = create(:user)
        sign_in user
        get edit_post_url(99_999)
        expect(response).to have_http_status(:not_found).and render_template(:index)
      end
    end
    describe '#update' do
      it "render index if post not found" do
        user = create(:user)
        sign_in user
        put post_url(99_999)
        expect(response).to have_http_status(:not_found).and render_template(:index)
      end
      it "render edit again when invalid params" do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        put post_url(post), params: { post: { title: "", body: "" } }
        expect(response).to have_http_status(:unprocessable_content).and render_template(:edit)
      end
      it "redirect_to show when valid params" do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        put post_url(post), params: { post: { title: post.title, body: post.body } }
        expect(response).to have_http_status(:see_other).and redirect_to(post_url(post))
      end
      it "render show when post does not belongs to current user" do
        user = create(:user)
        sign_in user
        post = create(:post)
        put post_url(post), params: { post: { title: post.title, body: post.body } }
        expect(response).to have_http_status(:forbidden).and render_template(:show)
      end
    end
    describe '#destroy' do
      it "render index when post not found" do
        user = create(:user)
        sign_in user
        delete post_url(99_999)
        expect(response).to have_http_status(:not_found).and render_template(:index)
      end
      it "render show when post does not belong to current user" do
        user = create(:user)
        sign_in user
        post = create(:post)
        delete post_url(post)
        expect(response).to have_http_status(:forbidden).and render_template(:show)
      end
      it "render index when post destroyed" do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        delete post_url(post)
        expect(response).to have_http_status(:see_other).and redirect_to(posts_url)
      end
      it "render show when post not destroyed" do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        allow(Post).to receive(:find).and_return(post)
        allow(post).to receive(:destroy).and_return(false)
        delete post_url(post)
        expect(response).to have_http_status(:internal_server_error).and render_template(:show)
      end
    end
  end
  context "without signed in user" do
    describe '#index' do
      it "returns http ok, redirecting to login page" do
        get "/"
        expect(response).to have_http_status(:ok).and render_template("devise/sessions/new")
      end
    end
  end
end
