# frozen_string_literal: true

# PostsController
class PostsController < ApplicationController
  before_action :authenticate_user!
  DEFAULT_OFFSET = 0

  def index; end

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
