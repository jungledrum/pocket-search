class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.find(session[:uid])
  end

  def unfollow
    follow_id = params[:follow_id] 
    user = User.find(session[:uid])
    unless follow_id.blank?
      follow = User.find(follow_id)
      user.follows.delete(follow)
    end

    redirect_to users_path
  end

  def follow
    follow_id = params[:follow_id] 
    user = User.find(session[:uid])
    unless follow_id.blank?
      follow = User.find(follow_id)
      user.follows << follow
    end

    redirect_to users_path
  end

end
