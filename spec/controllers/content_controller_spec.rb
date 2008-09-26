require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe ContentController do
  fixtures :users

  it 'redirects when logged in' do
    login_as :quentin
    get :index
    response.should be_success
  end
  
  it 'shows when not logged in' do
    get :index
    response.should be_success
  end

end
