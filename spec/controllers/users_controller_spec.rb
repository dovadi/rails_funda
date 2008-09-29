require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users, :roles, :roles_users 
  
  
  it 'add admin role for first user after activation' do
    User.delete_all
    create_user
    user = User.find_by_login('quire')
    get :activate, :activation_code => user.activation_code
    user.reload
    user.has_role?("admin").should be_true
  end
  
  it 'should send only welcome mail to first user without confirmation' do
    lambda do
      CONFIG[:no_activation_for_first_user] = true
      User.delete_all
      create_user
      sent = ActionMailer::Base.deliveries.first
      assert sent.body =~ /your account has been activated/
    end.should change(ActionMailer::Base.deliveries, :length).by(1)
  end
  
  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end


  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end

  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end

  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end

  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end

  it 'does suspend an user' do
    user = users(:quentin)
    login_as :admin
    get :suspend, {:id=>user.id} 
    user.reload
    user.state.should == "suspended"
    response.should be_redirect
    response.should redirect_to(users_path)
  end
  
   it 'does not suspend an user if not admin' do
    user = users(:quentin)
    login_as :quentin
    get :suspend, {:id=>user.id} 
    user.reload
    user.state.should_not == "suspended"
    response.should be_redirect
    response.should redirect_to(new_session_path)
  end

  it 'does unsuspend an user' do
    login_as :admin
    user = users(:quentin)
    user.state = 'suspended'
    user.save
    
    get :unsuspend, {:id=>user.id}
    user.reload
    user.state.should == "active"
    response.should be_redirect
    response.should redirect_to(users_path)
  end

  it 'does purge an user' do
    lambda do
      user = users(:quentin)
      login_as :admin
      get :purge, {:id=>user.id}
      response.should be_redirect
      response.should redirect_to(users_path)      
    end.should change(User, :count).by(-1)  
  end

  it 'does delete an user with provided password' do
    lambda do
      user = users(:aaron)
      login_as :aaron
      delete 'destroy',:id=>user.id, :password=>'monkey'
      user.reload
      user.state.should == "deleted"
      response.should be_redirect
      response.should redirect_to(login_path)      
    end.should_not change(User, :count)
  end
  
  it 'does not delete an user with wrong password' do
    lambda do
      user = users(:aaron)
      login_as :aaron
      delete 'destroy',:id=>user.id, :password=>'monkey23'
      user.reload
      user.state.should_not == "deleted"
      response.should be_redirect
    end.should_not change(User, :count)
  end
  
  it 'should update account info' do
    user = users(:quentin)
    login_as :quentin
    put :update, :id=>user.id, :user =>{:login=>'quentin_new', :email=>"fentoso@mambori.com"}
    user.reload
    user.login.should == "quentin_new"
    user.email.should == "fentoso@mambori.com"
    response.should be_redirect
    flash[:error ].should be_nil
  end
  
  it 'should not show edit form for other user then loggen in' do
    user = users(:quentin)
    login_as :aaron
    get :edit, :id=>user.id
    response.should be_redirect
    flash[:notice].should_not be_nil
  end
  
  it 'should show edit form for other user when user is admin' do
    user = users(:quentin)
    login_as :admin
    get :edit, :id=>user.id
    response.should_not be_redirect
    flash[:notice].should be_nil
  end
  
  it 'should not update account info when wrong data' do
    user = users(:quentin)
    login_as :quentin
    put :update, :id=>user.id, :user =>{:login=>'l og in', :email=>"floso $ compo mero"}
    response.should render_template("users/edit")
    flash[:error ].should_not be_nil
  end
  
  it 'should update password with old password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :change_password, :id=>user.id, :old_password=>'monkey', :user =>{:password=>'animal', :password_confirmation=>'animal'}
    user.reload
    user.crypted_password.should_not == old_pass
    User.authenticate(user.login, 'animal').should_not be_nil
    flash[:error ].should be_nil
  end
  
  it 'should not update password with wrong old password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :change_password, :id=>user.id, :old_password=>'monkey23', :user =>{:password=>'animal', :password_confirmation=>'animal'}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'should not update password with empty new password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :change_password, :id=>user.id, :old_password=>'monkey', :user =>{:password=>'', :password_confirmation=>''}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'should not update password with wrong confirmation for new password' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :change_password, :id=>user.id, :old_password=>'monkey', :user =>{:password=>'manilosa', :password_confirmation=>'maniloso'}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end

end

describe UsersController do
  fixtures :users
  
  describe "with livevalidations on signup" do
    it "response should be nil if login doesn't exists" do
      get :show, :id=>"check_user_login", :value=>"quenti"
      response.should be_success
      response.body.should == ""
    end
    it "response should be taken if login already exists" do
      get :show, :id=>"check_user_login", :value=>"quentin"
      response.should be_success
      response.body.should == "taken"
    end
    it "response should be nil if email doesn't exists" do
      get :show, :id=>"check_user_email", :value=>"quenti@example.com"
      response.should be_success
      response.body.should == ""
    end
    it "response should be taken if email already exists" do
      get :show, :id=>"check_user_email", :value=>"quentin@example.com"
      response.should be_success
      response.body.should == "taken"
    end
  end
  
  describe "with livevalidations on edit" do

    before do
      user = users(:quentin)
      login_as :quentin
    end

    it "response should be nil if login doesn't exists" do
      get :show, :id=>"check_user_login", :value=>"quenti"
      response.should be_success
      response.body.should == ""
    end
    it "response should be taken if login already exists" do
      get :show, :id=>"check_user_login", :value=>"quentin"
      response.should be_success
      response.body.should == ""
    end
    it "response should be nil if email doesn't exists" do
      get :show, :id=>"check_user_email", :value=>"quenti@example.com"
      response.should be_success
      response.body.should == ""
    end
    it "response should be taken if email already exists" do
      get :show, :id=>"check_user_email", :value=>"quentin@example.com"
      response.should be_success
      response.body.should == ""
    end
  end
   
end

describe UsersController do
  describe "route generation" do
    it "should route users's 'index' action correctly" do
      route_for(:controller => 'users', :action => 'index').should == "/users"
    end
    
    it "should route users's 'new' action correctly" do
      route_for(:controller => 'users', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'users', :action => 'create'} correctly" do
      route_for(:controller => 'users', :action => 'create').should == "/register"
    end
    
    it "should route users's 'show' action correctly" do
      route_for(:controller => 'users', :action => 'show', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'edit' action correctly" do
      route_for(:controller => 'users', :action => 'edit', :id => '1').should == "/users/1/edit"
    end
    
    it "should route users's 'update' action correctly" do
      route_for(:controller => 'users', :action => 'update', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'destroy' action correctly" do
      route_for(:controller => 'users', :action => 'destroy', :id => '1').should == "/users/1"
    end
  end
  
  describe "route recognition" do
    it "should generate params for users's index action from GET /users" do
      params_from(:get, '/users').should == {:controller => 'users', :action => 'index'}
      params_from(:get, '/users.xml').should == {:controller => 'users', :action => 'index', :format => 'xml'}
      params_from(:get, '/users.json').should == {:controller => 'users', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for users's new action from GET /users" do
      params_from(:get, '/users/new').should == {:controller => 'users', :action => 'new'}
      params_from(:get, '/users/new.xml').should == {:controller => 'users', :action => 'new', :format => 'xml'}
      params_from(:get, '/users/new.json').should == {:controller => 'users', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for users's create action from POST /users" do
      params_from(:post, '/users').should == {:controller => 'users', :action => 'create'}
      params_from(:post, '/users.xml').should == {:controller => 'users', :action => 'create', :format => 'xml'}
      params_from(:post, '/users.json').should == {:controller => 'users', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for users's show action from GET /users/1" do
      params_from(:get , '/users/1').should == {:controller => 'users', :action => 'show', :id => '1'}
      params_from(:get , '/users/1.xml').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/users/1.json').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's edit action from GET /users/1/edit" do
      params_from(:get , '/users/1/edit').should == {:controller => 'users', :action => 'edit', :id => '1'}
    end
    
    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      params_from(:put , '/users/1').should == {:controller => 'users', :action => 'update', :id => '1'}
      params_from(:put , '/users/1.xml').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/users/1.json').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's destroy action from DELETE /users/1" do
      params_from(:delete, '/users/1').should == {:controller => 'users', :action => 'destroy', :id => '1'}
      params_from(:delete, '/users/1.xml').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/users/1.json').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'json'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route users_path() to /users" do
      users_path().should == "/users"
      formatted_users_path(:format => 'xml').should == "/users.xml"
      formatted_users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      formatted_new_user_path(:format => 'xml').should == "/users/new.xml"
      formatted_new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      formatted_user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      formatted_user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end
