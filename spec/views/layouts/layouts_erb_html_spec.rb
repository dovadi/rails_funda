require File.dirname(__FILE__) + '/../../spec_helper'

describe "Layout" do
  it 'should render application.html.erb' do
    render "/layouts/application.html.erb"
    response.should be_valid_xhtml
  end
  
  it 'should render streamlined.rhtml' do
    render "/layouts/streamlined.rhtml"
    response.should be_success
  end
end
