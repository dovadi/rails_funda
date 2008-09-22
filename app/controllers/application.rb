# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
 
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => CONFIG[:secret_protect_from_forgery]
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  before_filter :check_no_users
  # redirect to signup page if no users exists
  def check_no_users
    return if params["controller"] == 'users' and ['new', 'create'].include?(params["action"])
    redirect_to signup_path unless logged_in? or User.count() > 0  
  end
end
