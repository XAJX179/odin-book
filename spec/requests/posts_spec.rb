# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Posts", type: :request do
  context "with signed in user" do
    describe '#index' do
      context 'on root path' do
        it "returns http moved_permanently and redirects to /posts" do
          user = create(:user)
          sign_in user
          get root_path
          expect(response).to have_http_status(:moved_permanently).and redirect_to(posts_url)
        end
      end

      context 'on /posts' do
        it "returns http ok and renders :index" do
          user = create(:user)
          sign_in user
          get posts_url
          expect(response).to have_http_status(:ok).and render_template(:index)
        end
      end
    end
    describe '#all' do
      it "returns http ok and renders :all" do
          user = create(:user)
          sign_in user
          get all_posts_url
          expect(response).to have_http_status(:ok).and render_template(:all)
      end
    end
    describe '#load_all' do
      it "returns http ok and performs turbo_stream actions" do
          8.times { create(:post) }
          user = create(:user)
          sign_in user
          get load_all_posts_url(format: "turbo_stream")
          expect(response).to have_http_status(:ok).and render_template(:load_all)
          assert_turbo_stream(action: "before", target: "posts-loader")
          assert_turbo_stream(action: "replace", target: "posts-loader")
      end
      it "performs remove loader turbo_stream action if no posts available!" do
          user = create(:user)
          sign_in user
          get load_all_posts_url(format: "turbo_stream")
          expect(response).to have_http_status(:ok)
          assert_turbo_stream(action: "replace", target: "posts-loader") do
            assert_select "template p", text: /End/
          end
      end
    end
    describe '#feed' do
      it "returns http ok and renders :feed" do
          user = create(:user)
          sign_in user
          get feed_posts_url
          expect(response).to have_http_status(:ok).and render_template(:feed)
      end
    end
    describe '#load_feed' do
      it "returns http ok and performs turbo_stream actions" do
          user = create(:user)
          8.times { create(:post, author: user) }
          sign_in user
          get load_feed_posts_url(format: "turbo_stream")
          expect(response).to have_http_status(:ok).and render_template(:load_feed)
          assert_turbo_stream(action: "before", target: "posts-loader")
          assert_turbo_stream(action: "replace", target: "posts-loader")
      end
      it "performs remove loader turbo_stream action if no posts available!" do
          user = create(:user)
          8.times { create(:post) }
          sign_in user
          get load_feed_posts_url(format: "turbo_stream")
          expect(response).to have_http_status(:ok)
          assert_turbo_stream(action: "replace", target: "posts-loader") do
            assert_select "template p", text: /End/
          end
      end
    end
    describe '#index_by_user' do
      it "when user found it returns http ok and renders :feed" do
          user = create(:user)
          create(:post, author: user)
          sign_in user
          get posts_index_for_user_url(user)
          expect(response).to have_http_status(:ok).and render_template(:index_by_user)
      end
      it "when user NOT found it returns http ok and renders :index" do
          user = create(:user)
          create(:post, author: user)
          sign_in user
          get posts_index_for_user_url(99_999)
          expect(response).to have_http_status(:not_found).and render_template(:index)
      end
    end
    describe '#load_by_user' do
      it "returns http ok and performs turbo_stream actions" do
          user = create(:user)
          8.times { create(:post, author: user) }
          sign_in user
          get load_posts_for_user_url(id: user.id, format: "turbo_stream")
          expect(response).to have_http_status(:ok).and render_template(:load_by_user)
          assert_turbo_stream(action: "append", target: "index-by-user-posts")
          assert_turbo_stream(action: "replace", target: "posts-loader")
      end
      it "performs remove loader turbo_stream action if no posts available!" do
          user = create(:user)
          8.times { create(:post) }
          sign_in user
          get load_posts_for_user_url(id: user.id, format: "turbo_stream")
          expect(response).to have_http_status(:ok)
          assert_turbo_stream(action: "replace", target: "posts-loader") do
            assert_select "template p", text: /End/
          end
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
    describe "search" do
      it 'render search posts when search returns posts' do
        user = create(:user)
        sign_in user
        post = create(:post, author: user)
        query = post.title
        get search_posts_url(title: query)
        expect(response).to have_http_status(:ok).and render_template(:search)
        assert_select "#search-results", text: Regexp.new(query)
      end
      it 'render search posts when search returns posts' do
        user = create(:user)
        sign_in user
        get search_posts_url(title: 'hello')
        expect(response).to have_http_status(:ok).and render_template(:search)
        assert_select "#search-results", text: 'No results'
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
