class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if User.count == 1 && !CONFIG[:no_activation_for_first_user]
      UserMailer.deliver_signup_notification(user)  
    end  
    if User.count > 1
      UserMailer.deliver_signup_notification(user)  
    end
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated?
    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
  end
end
