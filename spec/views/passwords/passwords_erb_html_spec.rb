require File.dirname(__FILE__) + '/../../spec_helper'

describe "With passwords pages " do
  it 'should render new.html.erb' do
    render "/passwords/new.html.erb"
    response.should be_success
    response.should be_valid_xhtml_fragment
  end
  
  it 'should render show.html.erb' do
    user = mock(User, :login=>"dovadi")
    user.should_receive(:errors).any_number_of_times.and_return(ActiveRecord::Errors.new(user))
    user.should_receive(:email).and_return("")
    user.should_receive(:password).and_return("")
    user.should_receive(:password_confirmation).and_return("")
    assigns[:user] = user
    render "/passwords/show.html.erb"
    response.should be_success
    response.should be_valid_xhtml_fragment
  end
end
