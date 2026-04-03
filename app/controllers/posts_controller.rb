# frozen_string_literal: true

# PostsController
class PostsController < ApplicationController
  DEFAULT_OFFSET = 0

  def index; end

  def show
    @post = Post.show(params[:id])
    if @post.nil?
      flash.now.alert = "Post not found!"
      render :index, status: :not_found
    else
      render :show
    end
  end

  def new
    @post = Post.new
  end

  def edit
    begin
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Post not found!"
      render :index, status: :not_found
      return
    end

    if current_user.posts.include?(@post)
      render :edit
    else
      flash.now.alert = "You can't edit this post! contact author"
      render :show, status: :forbidden
    end
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash.notice = "Post Created!"
      redirect_to posts_url, status: :see_other
    else
      flash.now.alert = "Post Invalid! Could not be Created!"
      render :new, status: :unprocessable_content
    end
  end

  def update
    begin
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Post not found!"
      render :index, status: :not_found
      return
    end

    if current_user.posts.include?(@post)
      @post.update(post_params)
      if @post.valid?
        flash.notice = "Post updated!"
        redirect_to post_url, status: :see_other
      else
        flash.now.alert = "Post not valid! could not update!"
        render :edit, status: :unprocessable_content
      end
    else
      flash.now.alert = "You can't update this post! contact author"
      render :show, status: :forbidden
    end
  end

  def destroy
    begin
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Post not found!"
      render :index, status: :not_found
      return
    end

    if current_user.posts.include?(@post)
      @post.destroy
    else
      flash.now.alert = "You can't delete this post! contact author"
      render :show, status: :forbidden
      return
    end

    if @post.destroyed?
      flash.now.notice = "Post destroyed !"
      redirect_to posts_url, status: :see_other
    else
      render :show, status: :internal_server_error
    end
  end

  def all; end
  def feed; end

  def load_feed
    @offset = params[:offset]
    @posts = Post.load_feed(current_user, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @posts.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_feed" }
      end
    end
  end

  def load_all
    @offset = params[:offset]
    @posts = Post.load_all(@offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @posts.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_all" }
      end
    end
  end

  def index_by_user
    user_id = params[:id]
    @user = User.find(user_id)
  rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :index, status: :not_found
  end

  def load_by_user
    @offset = params[:offset]
    user_id = params[:id]
    begin
    @user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      flash.alert = "User not found!"
      redirect_to posts_url, status: :see_other
      return
    end
    @posts = Post.load_by_user(@user, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @posts.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_by_user" }
      end
    end
  end

  private

  def post_params
    params.expect(post: %i[title body])
  end
end
