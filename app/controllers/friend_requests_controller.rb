class FriendRequestsController < ApplicationController
  DEFAULT_OFFSET = 0

  def index; end

  def show; end

  def new
    @friend_request = FriendRequest.new
  end

  def create
    @friend_request = FriendRequest.new

    begin
      user = User.find_by!(name: params["friend_request"]["to"])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :new, status: :not_found
      return
    end

    existing_reqs = FriendRequest.between(current_user, user)
    if current_user.friends.include? user
      flash.now.alert = "Already friended!"
      render :new, status: :unprocessable_content
    elsif existing_reqs.exists?
      flash.now.alert = "your already sent or received a request!"
      render :new, status: :unprocessable_content
    else
      @friend_request = current_user.outgoing_friend_requests.build(to: user, status: :pending)
      if @friend_request.save
        flash.now.notice = "Friend request sent!"
        respond_to do |format|
          format.turbo_stream { head :ok }
        end
      else
        flash.now.alert = "Friend request invalid! could not be created!"
        render :new, status: :unprocessable_content
      end
    end
  end

  def destroy
    begin
      @friend_request = FriendRequest.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Friend request not found"
      render :index, status: :not_found
      return
    end

    if @friend_request.to == current_user || @friend_request.from == current_user
      @friend_request.destroy
    else
      flash.now.alert = "Not allowed to delete other's friend request"
      render :index, status: :forbidden
      return
    end

    if @friend_request.destroyed?
      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "Friend request destroyed !"
          head :ok
        end
      end
    else
      flash.now.alert = "Server Error"
      render :index, status: :internal_server_error
    end
  end

  def incoming; end

  def outgoing; end

  def load_incoming
    @offset = params[:offset]
    @friend_requests = FriendRequest.load_incoming_by_user(current_user, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @friend_requests.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_incoming" }
      end
    end
  end

  def load_outgoing
    @offset = params[:offset]
    @friend_requests = FriendRequest.load_outgoing_by_user(current_user, @offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @friend_requests.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_outgoing" }
      end
    end
  end

  def accept
    begin
      @friend_request = FriendRequest.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "Friend request not found"
      render :index, status: :not_found
      return
    end

    if @friend_request.to == current_user
      flash.now.notice = "New friend added!"
      Friendship.find_or_create_by(user: current_user, friend: @friend_request.from)
      Friendship.find_or_create_by(user: @friend_request.from, friend: current_user)
      @friend_request.destroy
      @friend_request.opposite_request&.destroy
    else
      flash.now.alert = "Not allowed to accept other's incoming friend request"
      render :index, status: :forbidden
    end
  end
end
