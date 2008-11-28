require File.dirname(__FILE__) + '/../../spec_helper'

describe "With User emails" do
  
  it 'should render activation email' do
    user = mock(User, :login=>"dovadi")
    assigns[:user] = user
    assigns[:url] = "http://google.com"
    render "/user_mailer/activation.erb"
    response.should be_success    
    response.should be_valid_xhtml_fragment
  end
  
  it 'should render forgot password mail' do
    user = mock(User, :login=>"dovadi")
    assigns[:key] = "23423423423"
    render "/user_mailer/forgot_password.html.erb"
    response.should be_success    
    response.should be_valid_xhtml_fragment
  end
  
  it 'should render signup notification' do
    user = mock(User, :login=>"oleg")
    assigns[:user] = user
    assigns[:url] = "http://google.com"
    render "/user_mailer/signup_notification.erb"
    response.should be_success    
    response.should be_valid_xhtml_fragment
  end
end
