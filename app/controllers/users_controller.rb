class UsersController < ApplicationController
  DEFAULT_OFFSET = 0

  def index; end

  def show
      @user = User.find(params[:user_id])
      @requests = FriendRequest.between(@user, current_user)
  rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :index, status: :not_found
  end

  def edit
      @profile = User.find(params[:user_id]).profile
  rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :index, status: :not_found
  end

  def update
    begin
      user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :index, status: :not_found
      return
    end

    if current_user == user
      @profile = user.profile
      @profile.update(profile_params)
      if @profile.valid?
        flash.notice = "Profile updated!"
        redirect_to user_profile_url, status: :see_other
      else
        flash.now.alert = "Profile not valid! could not update!"
        render :edit, status: :unprocessable_content
      end
    else
      flash.now.alert = "You can't update this profile! contact user"
      render :show, status: :forbidden
    end
  end

  def load_all
    @offset = params[:offset]
    @users = User.load_all(@offset || DEFAULT_OFFSET)

    respond_to do |format|
      if @users.empty?
        format.turbo_stream { render "remove_loader" }
      else
        format.turbo_stream { render "load_all" }
      end
    end
  end

  def search
    @users = User.search(params[:name])
    render "search", layout: false
  end

  def profile_buttons
    begin
      @user = User.find(params[:user_id])
      @requests = FriendRequest.between(@user, current_user)
    rescue ActiveRecord::RecordNotFound
      flash.now.alert = "User not found!"
      render :index, status: :not_found
      return
    end

    render partial: "buttons", locals: { user: @user, requests: @requests }
  end

  private

  def profile_params
    params.expect(profile: %i[display_name about avatar])
  end
end
