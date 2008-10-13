require File.dirname(__FILE__) + '/../../spec_helper'

describe "users mails" do
  
  it 'renders activation email' do
    user = mock(User, :login=>"dovadi")
    assigns[:user] = user
    assigns[:url] = "http://google.com"
    render "/user_mailer/activation.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'renders forgot password mail' do
    user = mock(User, :login=>"dovadi")
    assigns[:key] = "23423423423"
    render "/user_mailer/forgot_password.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'renders signup notification' do
    user = mock(User, :login=>"oleg")
    assigns[:user] = user
    assigns[:url] = "http://google.com"
    render "/user_mailer/signup_notification.erb"
    response.should be_valid_xhtml_fragment
  end
end
