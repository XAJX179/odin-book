class LikesController < ApplicationController
  def create
    begin
    post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Post not found!"
      render :index, status: :not_found
      return
    end

    if post.liked_by?(current_user)
      flash.alert = "You already liked this post!"
      redirect_to post_path(post)
    else
      flash.now.notice = "Like added!"
      like = PostLike.create(post: post, author: current_user)
      respond_to do |format|
        format.turbo_stream { render "post_likes/create", locals: { post_id: post.id, like_id: like.id } }
      end
    end
  end

  def destroy
    begin
      post_like = PostLike.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Like not found!"
      render :index, status: :not_found
      return
    end

    if post_like.author == current_user
      flash.now.notice = "Like removed!"
      post_like.destroy
      respond_to do |format|
        format.turbo_stream { render "post_likes/remove", locals: { post_id: params[:post_id] } }
      end
    else
      flash.alert = "You can't change like for other users!"
      redirect_to post_path(params[:post_id])
    end
  end
end
