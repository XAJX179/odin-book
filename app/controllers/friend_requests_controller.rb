class FriendRequestsController < ApplicationController
  DEFAULT_OFFSET = 0

  def index; end

  def show; end
  def new; end
  def create; end

  def destroy; end

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
end
