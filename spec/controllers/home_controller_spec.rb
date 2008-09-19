require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe HomeController do
  fixtures :users

  it 'show homepage when logged in' do
    login_as :quentin
    get :index
    response.should be_success
  end
  
  it 'redirect when not logged in' do
    get :index
    response.should be_redirect
  end
end