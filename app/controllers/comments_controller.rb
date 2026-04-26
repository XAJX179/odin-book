class CommentsController < ApplicationController
  # TODO: finish index and show and use turbo to start making it nested and lazy load
  def index; end

  def show
    comment = PostComment.show(params[:id])
    render "show", locals: { comment: comment }
  end

  def new
    @post_id = params[:post_id]
    @parent_id = params[:parent_id] if params[:parent_id]
    @comment = PostComment.new
  end

  def edit
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      @parent_comment = PostComment.find(params[:parent_id]) unless params[:parent_id].nil?
      @parent_id = params[:parent_id]
      @post_id = params[:post_id]
      @comment = PostComment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to posts_path, status: :see_other
    end
  end

  def create
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      @parent_comment = PostComment.find(params[:post_comment][:parent_id]) unless params[:post_comment][:parent_id].empty?
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to posts_path, status: :see_other
      return
    end

    @parent_id = params[:post_comment][:parent_id]
    @post_id = params[:post_id]
    @comment = current_user.post_comments.build(comment_params)
    if @comment.save
      flash.now.notice = "Comment Created!"
      respond_to do |format|
        format.turbo_stream { render "create", locals: { parent_id: @parent_id, parent_comment: @parent_comment } }
        format.html { redirect_to post_path(@post), status: :see_other }
      end
    else
      flash.now.alert = "Comment Invalid! Could not be Created!"
      respond_to do |format|
        format.turbo_stream { render "new", locals: { parent_id: @parent_id, parent_comment: @parent_comment }, status: :unprocessable_content }
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      @parent_comment = PostComment.find(params[:post_comment][:parent_id]) unless params[:post_comment][:parent_id].empty?
      @parent_id = params[:parent_id]
      @post_id = params[:post_id]
      @comment = PostComment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to posts_path, status: :see_other
      return
    end

    if @comment.update(comment_params)
      flash.now.notice = "Comment updated!"
      head :ok
    else
      flash.now.alert = "Comment Invalid! Could not be updated!"
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    begin
      comment = PostComment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to posts_path, status: :see_other
      return
    end

    if comment.author == current_user && comment.destroy
      flash.now.notice = "Comment Deleted!"
      head :ok
    else
      flash.alert = "Comment Could not be Deleted!"
      redirect_to posts_path, status: :see_other
    end
  end

  def buttons
    @comment = PostComment.find(params[:id])
    @post_id = params[:post_id]
  end

  private

  def comment_params
    params.expect(post_comment: %i[parent_id post_id body])
  end
end
