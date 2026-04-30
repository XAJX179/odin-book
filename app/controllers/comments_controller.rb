class CommentsController < ApplicationController
  DEFAULT_OFFSET = 0
  # TODO: finish index and show and use turbo to start making it nested and lazy load
  def index
      @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
  end

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

  def load
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      parent_id = params[:parent_id]
      @parent_comment = PostComment.find(parent_id) unless parent_id.nil? || parent_id == ""
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to post_path(@post), status: :see_other
      return
    end

    @offset = params[:offset]
    @comments = PostComment.load(@post, @parent_comment, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @comments.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load" }
      end
    end
  end

  def replies
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      parent_id = params[:id]
      @parent_comment = PostComment.where(id: parent_id, post_id: @post.id).first unless parent_id.nil? || parent_id == ""
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to post_path(@post), status: :see_other
      return
    end

    respond_to do |format|
      format.turbo_stream { render "replies" }
    end
  end

  def load_replies
    begin
      @post = Post.find(params[:post_id])
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Post not found!"
      redirect_to posts_path, status: :see_other
      return
    end
    begin
      parent_id = params[:id]
      @parent_comment = PostComment.where(id: parent_id, post_id: @post.id).first unless parent_id.nil? || parent_id == ""
    rescue ActiveRecord::RecordNotFound
      flash.alert = "Comment not found!"
      redirect_to post_path(@post), status: :see_other
      return
    end

    @offset = params[:offset]
    @replies = PostComment.load(@post, @parent_comment, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @replies.empty?
        format.turbo_stream { render "remove_replies_loader" }
      else
        format.turbo_stream { render "load_replies" }
      end
    end
  end

  private

  def comment_params
    params.expect(post_comment: %i[parent_id post_id body])
  end
end
