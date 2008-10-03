require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe PasswordsController do
  fixtures :users, :roles 
  it 'should update password with old password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :update, :old_password=>'monkey', :user =>{:password=>'animal', :password_confirmation=>'animal'}
    user.reload
    user.crypted_password.should_not == old_pass
    User.authenticate(user.login, 'animal').should_not be_nil
    flash[:error ].should be_nil
  end
  
  it 'should not update password with wrong old password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :update, :old_password=>'monkey23', :user =>{:password=>'animal', :password_confirmation=>'animal'}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'should not update password with empty new password provided' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :update, :id=>user.id, :old_password=>'monkey', :user =>{:password=>'', :password_confirmation=>''}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'should not update password with wrong confirmation for new password' do
    user = users(:quentin)
    login_as :quentin
    old_pass = user.crypted_password.dup
    post :update, :id=>user.id, :old_password=>'monkey', :user =>{:password=>'manilosa', :password_confirmation=>'maniloso'}
    user.reload
    user.crypted_password.should == old_pass
    User.authenticate(user.login, 'animal').should be_nil
    flash[:error ].should_not be_nil
  end
  
  it "should send mail on recover password request when right email is given" do
    lambda do
      user = users(:quentin)
      post :create, :email=>user.email
      flash[:notice].should_not be_nil
      response.should be_redirect
    end.should change(ActionMailer::Base.deliveries, :length).by(1)
  end
  
  it "should not send mail on recover password request when right email is given but user is not active" do
    lambda do
      user = users(:quentin)
      user.suspend! 
      post :create, :email=>user.email
      flash[:notice].should_not be_nil
    end.should_not change(ActionMailer::Base.deliveries, :length)
  end
  
  it "should not send mail on recover password request when wrong email is given" do
    lambda do
      user = users(:quentin)
      post :create, :email=>"ssss@aaaaa.com"
      flash[:notice].should_not be_nil
    end.should_not change(ActionMailer::Base.deliveries, :length)
  end
  
  it "should show recover password page" do
    user = users(:quentin)
    post :create, :email=>user.email
    get :show, :key=>user.remember_token
    response.should_not be_redirect
  end
  
  it "should change password on recover page" do
    user = users(:aaron)
    old_pass = user.crypted_password
    user.activate!
    user.remember_me
    post :update, :key=>user.remember_token,  :user =>{:password=>'manilosa', :password_confirmation=>'manilosa'}
    response.should redirect_to(login_path)  
    user.reload
    user.crypted_password.should_not == old_pass
  end
end  