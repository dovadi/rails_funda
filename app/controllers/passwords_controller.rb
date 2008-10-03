class PasswordsController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user.nil?
      flash[:notice] = 'No active user registered with given email.'
      redirect_to new_password_path
      return
    elsif !user.active?
      flash[:notice] = 'User with given email is not activated yet.'
      redirect_to new_password_path
      return
    end
    if user.forgot_password
      flash[:notice] = "Check your email for instructions how to recover your password."
      redirect_to main_path
    end 
  end
  
  def update
    if logged_in?
      @user = current_user
      user = User.authenticate(@user.login, params[:old_password])
      if user
        if !params[:user][:password].blank? && !params[:user][:password_confirmation].blank? && @user.update_attributes(params[:user])
          flash[:success] = "Your password is changed."
          redirect_to home_path
        else
          flash[:error]  = "Password is not changed because new password not provided."
          redirect_to edit_user_path(@user)
        end
      else
        flash[:error]  = "Password is not changed because old password is not valid."
        redirect_to edit_user_path(@user)
      end
    else
      redirect_to home_path unless params[:key]
      @key = params[:key]
      @user = User.find_by_remember_token(@key)
      if @user.update_attributes(params[:user])
        flash[:notice] = "Now you can login with your new password."
        @user.forget_me
        kill_remember_cookie!
        redirect_to login_path
      end
    end
  end
  
  def show
    redirect_to home_path unless params[:key]
    flash[:notice] = "You can set new password now."
    @key = params[:key]
    @user = User.find_by_remember_token(@key)
    redirect_to home_path unless @user
  end
  
end
