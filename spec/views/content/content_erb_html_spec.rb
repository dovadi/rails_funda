require File.dirname(__FILE__) + '/../../spec_helper'

describe "content" do

  it 'content index when logged in' do
    assigns[:current_user] = mock(User, :login=>"dovadi")
    render "/content/index.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
  it 'content index when not logged in' do
    render "/content/index.html.erb"
    response.should be_valid_xhtml_fragment
  end
end
