require File.dirname(__FILE__) + '/../../spec_helper'

describe "users pages" do
  it 'renders user_bar when logged in' do
    user = mock(User, :login=>"dovadi")
    user.should_receive(:has_role?).and_return(true)
    assigns[:current_user] = user
    render "/users/_user_bar.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'renders edit' do
    
    user = mock(User, :login=>"dovadi")
    user.should_receive(:errors).any_number_of_times.and_return(ActiveRecord::Errors.new(user))
    user.should_receive(:email).and_return("")
    user.should_receive(:login).and_return("")
    user.should_receive(:password_confirmation=).and_return("")
    user.should_receive(:password=).and_return("")
    user.should_receive(:password).and_return("")
    user.should_receive(:password_confirmation).and_return("")
    assigns[:user] = user
    render "/users/edit.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'renders new' do
    assigns[:user]
    user = mock(User, :login=>"dovadi")
    user.should_receive(:errors).any_number_of_times.and_return(ActiveRecord::Errors.new(user))
    user.should_receive(:email).and_return("")
    user.should_receive(:login).and_return("")
    user.should_receive(:password_confirmation=).and_return("")
    user.should_receive(:password=).and_return("")
    user.should_receive(:password).and_return("")
    user.should_receive(:password_confirmation).and_return("")
    assigns[:user] = user
    render "/users/new.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'renders user_bar when not logged in' do
    render "/users/_user_bar.html.erb"
    response.should be_valid_xhtml_fragment
  end
end
