# frozen_string_literal: true

# PostsController
class PostsController < ApplicationController
  before_action :authenticate_user!
  DEFAULT_OFFSET = 0

  def index; end

  def show; end
  def new; end
  def edit; end
  def create; end
  def update; end
  def destroy; end

  def user_feed_index; end

  def load_user_feed_posts
    @offset = params[:offset]
    @posts = Post.load_user_feed_posts(current_user, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @posts.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_user_feed_posts" }
      end
    end
  end

  def load_posts
    @offset = params[:offset]
    @posts = Post.load_posts(@offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @posts.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_posts" }
      end
    end
  end
end
