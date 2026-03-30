class FriendsController < ApplicationController
  DEFAULT_OFFSET = 0
  def index
    @user = User.find_by(id: params[:user_id])
    return if @user

    flash.alert = "User not found!"
    redirect_to posts_url, status: :see_other
  end

  def load_for_user
    @offset = params[:offset]
    @id = params[:id]
    @user = User.find(@id)
    @friends = @user.friends.limit(Friendship::LIMIT).offset(@offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @friends.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_friends" }
      end
    end
  end

  def destroy
    user = User.find_by(id: params[:user_id])

    if user
      if user != current_user
        flash.alert = "Not allowed to remove other user's friends"
        redirect_to posts_url, status: :see_other
        return
      end
      friend_id = params[:id].to_i
      if user.friend_ids.include? friend_id
        Friendship.delete_for(user.id, friend_id)
        head :ok
      else
        flash.alert = "Friend not found!"
        redirect_to user_profile_url(user), status: :see_other
      end
    else
      flash.alert = "User not found!"
      redirect_to posts_url, status: :see_other
    end
  end
end
