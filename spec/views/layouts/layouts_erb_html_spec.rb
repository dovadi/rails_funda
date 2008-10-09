require File.dirname(__FILE__) + '/../../spec_helper'

describe "layouts" do
  it 'renders application' do

    usr = mock(User, :login=>"dovadi")
    usr.should_receive(:has_role?).and_return(true)
    assigns[:current_user] = usr
    render "/layouts/application.html.erb"
    response.should be_valid_xhtml
  end
  
  it 'renders streamlined' do
    assigns[:current_user] = mock(User, :login=>"dovadi")
    render "/layouts/streamlined.rhtml"
    response.should be_success
  end
end
