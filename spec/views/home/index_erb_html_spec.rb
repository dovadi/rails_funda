require File.dirname(__FILE__) + '/../../spec_helper'

describe "/home/index.html.erb" do

  it 'renders' do
    user = mock(User, :login=>"dovadi")
    @controller.template.stub!(:current_user).and_return(user)
    render "/home/index.html.erb"
    response.should be_valid_xhtml_fragment
  end
  
end
