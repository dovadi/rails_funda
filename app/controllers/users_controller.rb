class UsersController < ApplicationController
  
  # Protect these actions behind an admin login
  #before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :edit, :update, :change_password]
  require_role "admin", :only => [:edit, :update, :change_password, :destroy], :unless =>"@user == current_user"
  require_role "admin", :only => [:suspend, :unsuspend, :purge]

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    activate_now = (CONFIG[:no_activation_for_first_user] and User.count.zero?)
    if @user && @user.valid?
      @user.register! 
      if activate_now
        @user.roles << (Role.find_by_name('admin') or Role.create!(:name=>'admin'))
        @user.activate!  
      end
    end
    success = @user && @user.valid?
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      if activate_now
        flash[:notice] = "Signup complete! Please sign in to continue."
      else
        flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."  
      end
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.roles << (Role.find_by_name('admin') or Role.create!(:name=>'admin')) if User.count == 1
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
  
  def edit

  end
  
  def update
    params[:user].delete_if{|key, value| [:password, :password_confirmation].include?(key)}
    if @user.update_attributes(params[:user])
      redirect_to :controller=>:home
      flash[:success] = "Your account is updated"
    else
      flash[:error]  = "Account can not be updated because of errors in validation."
      render :action => 'edit'
    end
  end
  
  def change_password
    user = User.authenticate(@user.login, params[:old_password])
    if user
      if !params[:user][:password].blank? && !params[:user][:password_confirmation].blank? && @user.update_attributes(params[:user])
        flash[:success] = "Your password is changed."
        redirect_to home_path
      else
        flash[:error]  = "Password is not changed because new password not provided."
        render :action=>:edit, :id=>@user
      end
    else
      flash[:error]  = "Password is not changed because old password is not valid."
      render :action=>:edit, :id=>@user
    end  
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end
  
  def destroy
    if @user.authenticated?(params[:password])
      @user.delete!
      logout_killing_session!
      flash[:success] = "Account is deleted."
      redirect_to login_path
    else
      flash[:error] = "Wrong password, account can not be deleted."
      flash[:not_deleted] = true
      redirect_to :action=>:edit, :id=>@user.id
    end
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_user
    @user = User.find_by_id(params[:id])
  end
end
