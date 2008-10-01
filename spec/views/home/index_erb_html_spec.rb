require File.dirname(__FILE__) + '/../../spec_helper'

describe "/home/index.html.erb" do

  it 'renders' do
    assigns[:current_user] = mock(User, :login=>"dovadi")
    render "/home/index.html.erb"
    response.should be_valid_xhtml_fragment
  end
end
