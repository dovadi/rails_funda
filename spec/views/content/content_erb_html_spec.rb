require File.dirname(__FILE__) + '/../../spec_helper'

describe "/content/index.html.erb" do

  it 'should render when logged in' do
    user = mock(User, :login=>"dovadi")
    @controller.template.stub!(:logged_in?).and_return(true) 
    @controller.template.stub!(:current_user).and_return(user)

    render "/content/index.html.erb"
    response.should be_success
    response.should be_valid_xhtml_fragment
  end
  
  it 'should render when not logged in' do
    @controller.template.stub!(:logged_in?).and_return(false) 
    render "/content/index.html.erb"
    response.should be_success    
    response.should be_valid_xhtml_fragment
  end
end
