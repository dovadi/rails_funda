require File.dirname(__FILE__) + '/../../../spec_helper'
require 'controller_spec_controller'

['integration', 'isolation'].each do |mode|
  describe "A controller example running in #{mode} mode", :type => :controller do
    controller_name :controller_spec
    integrate_views if mode == 'integration'

    accesses_configured_helper_methods

    it "should use the controller as the implicit subject" do
      subject.should == controller
    end

    describe "with a specified subject" do
      subject { 'specified' }
      
      it "should use the specified subject instead of the controller" do
        subject.should == 'specified'
      end
    end
    
    it "should provide controller.session as session" do
      get 'action_with_template'
      session.should equal(controller.session)
    end
  
    it "should provide the same session object before and after the action" do
      session_before = session
      get 'action_with_template'
      session.should equal(session_before)
    end
  
    it "should keep the same data in the session before and after the action" do
      session[:foo] = :bar
      get 'action_with_template'
      session[:foo].should == :bar
    end
  
    it "should ensure controller.session is NOT nil before the action" do
      controller.session.should_not be_nil
      get 'action_with_template'
    end
    
    it "should ensure controller.session is NOT nil after the action" do
      get 'action_with_template'
      controller.session.should_not be_nil
    end
    
    it "should allow specifying a partial with partial name only" do
      get 'action_with_partial'
      response.should render_template("_partial")
    end
    
    it "should allow specifying a partial with should_receive(:render)" do
      controller.should_receive(:render).with(:partial => "controller_spec/partial")
      get 'action_with_partial'
    end
    
    it "should allow specifying a partial with should_receive(:render) with object" do
      controller.should_receive(:render).with(:partial => "controller_spec/partial", :object => "something")
      get 'action_with_partial_with_object', :thing => "something"
    end
    
    it "should allow specifying a partial with should_receive(:render) with locals" do
      controller.should_receive(:render).with(:partial => "controller_spec/partial", :locals => {:thing => "something"})
      get 'action_with_partial_with_locals', :thing => "something"
    end
    
    it "should yield to render :update" do
      template = stub("template")
      controller.should_receive(:render).with(:update).and_yield(template)
      template.should_receive(:replace).with(:bottom, "replace_me", :partial => "non_existent_partial")
      get 'action_with_render_update'
    end
    
    it "should allow a path relative to RAILS_ROOT/app/views/ when specifying a partial" do
      get 'action_with_partial'
      response.should render_template("controller_spec/_partial")
    end
    
    it "should provide access to flash" do
      get 'action_which_sets_flash'
      flash[:flash_key].should == "flash value"
    end
    
    it "should provide access to flash values set after a session reset" do
      get 'action_setting_flash_after_session_reset'
      flash[:after_reset].should == "available"
    end
    
    it "should not provide access to flash values set before a session reset" do
      get 'action_setting_flash_before_session_reset'
      flash[:before_reset].should_not == "available"
    end

    it "should provide access to session" do
      session[:session_key] = "session value"
      lambda do
        get 'action_which_gets_session', :expected => "session value"
      end.should_not raise_error
    end

    describe "handling should_receive(:render)" do
      it "should warn" do
        controller.should_receive(:render).with(:template => "controller_spec/action_with_template")
        get :action_with_template
      end
    end
    
    describe "handling should_not_receive(:render)" do
      it "should warn" do
        controller.should_not_receive(:render).with(:template => "the/wrong/template")
        get :action_with_template
      end
    end
    
    describe "setting cookies in the request" do
    
      it "should support a String key" do
        cookies['cookie_key'] = 'cookie value'
        get 'action_which_gets_cookie', :expected => "cookie value"
      end

      it "should support a Symbol key" do
        cookies[:cookie_key] = 'cookie value'
        get 'action_which_gets_cookie', :expected => "cookie value"
      end
      
      it "should support a Hash value" do
        cookies[:cookie_key] = {'value' => 'cookie value', 'path' => '/not/default'}
        get 'action_which_gets_cookie', :expected => {'value' => 'cookie value', 'path' => '/not/default'}
      end
      
    end
  
    describe "reading cookies from the response" do
  
      it "should support a Symbol key" do
        get 'action_which_sets_cookie', :value => "cookie value"
        if Rails::VERSION::STRING >= "2.3"
          cookies[:cookie_key].should == "cookie+value"
        else
          cookies[:cookie_key].should == ["cookie value"]
        end
      end

      it "should support a String key" do
        get 'action_which_sets_cookie', :value => "cookie value"
        if Rails::VERSION::STRING >= "2.3"
          cookies['cookie_key'].should == "cookie+value"
        else
          cookies['cookie_key'].should == ["cookie value"]
        end
      end
    
    end
    
    describe "with an error that is not rescued in the controller" do
      context "without rails' error handling" do
        it "raises the error" do
          lambda do
            get 'other_error_action'
          end.should raise_error(ControllerSpecController::UnRescuedError)
        end
      end
      context "with rails' error handling" do
        it "does not raise the error" do
          pending "deal with use_rails_error_handling" do
            controller.use_rails_error_handling!
            lambda do
              get 'other_error_action'
            end.should_not raise_error
          end
        end
      end
    end
    
    describe "with an error that is rescued in the controller" do
      context "without rails' error handling" do
        it "does not raise error" do
          lambda do
            get 'rescued_error_action'
          end.should_not raise_error
        end

        it "executes rescue_from" do
          get 'rescued_error_action'
          response.body.should == 'Rescued!'
        end
      end

      context "with rails' error handling" do
        before(:each) do
          controller.use_rails_error_handling!
        end
        it "does not raise error" do
          lambda do
            get 'rescued_error_action'
          end.should_not raise_error
        end

        it "executes rescue_from" do
          get 'rescued_error_action'
          response.body.should == 'Rescued!'
        end
      end
    end

    class CustomRouteSpecController < ActionController::Base; end
    class RspecOnRailsSpecsController < ActionController::Base; end

    it "should support custom routes" do
      route_for(:controller => "custom_route_spec", :action => "custom_route").
        should == "/custom_route"
    end

    it "should support existing routes" do
      route_for(:controller => "controller_spec", :action => "some_action").
        should == "/controller_spec/some_action"
    end

    it "should support existing routes with additional parameters" do
      route_for(:controller => "controller_spec", :action => "some_action", :param => '1').
        should == "/controller_spec/some_action?param=1"
    end
    
    it "recognizes routes with methods besides :get" do
      route_for(:controller => "rspec_on_rails_specs", :action => "update", :id => "37").
        should == {:path => "/rspec_on_rails_specs/37", :method => :put}
    end

    it "should generate params for custom routes" do
      params_from(:get, '/custom_route').
        should == {:controller => "custom_route_spec", :action => "custom_route"}
    end

    it "should generate params for existing routes" do
      params_from(:get, '/controller_spec/some_action').
        should == {:controller => "controller_spec", :action => "some_action"}
    end

    it "should generate params for an existing route with a query parameter" do
      params_from(:get, '/controller_spec/some_action?param=1').
        should == {:controller => "controller_spec", :action => "some_action", :param => '1'}
    end

    it "should generate params for an existing route with multiple query parameters" do
      params_from(:get, '/controller_spec/some_action?param1=1&param2=2').
        should == {:controller => "controller_spec", :action => "some_action", :param1 => '1', :param2 => '2' }
    end

    it "should expose instance vars through the assigns hash" do
      get 'action_setting_the_assigns_hash'
      assigns[:indirect_assigns_key].should == :indirect_assigns_key_value
    end

    it "should expose instance vars through the assigns hash that are set to false" do
      get 'action_that_assigns_false_to_a_variable'
      assigns[:a_variable].should be_false
    end

    it "should NOT complain when calling should_receive with arguments other than :render" do
      controller.should_receive(:anything_besides_render)
      lambda {
        controller.rspec_verify
      }.should raise_error(Exception, /expected :anything_besides_render/)
    end

    it "should not run a skipped before_filter" do
      lambda {
        get 'action_with_skipped_before_filter'
      }.should_not raise_error
    end
  end

  describe "Given a controller spec for RedirectSpecController running in #{mode} mode", :type => :controller do
    controller_name :redirect_spec
    integrate_views if mode == 'integration'

    it "a redirect should ignore the absence of a template" do
      get 'action_with_redirect_to_somewhere'
      response.should be_redirect
      response.redirect_url.should == "http://test.host/redirect_spec/somewhere"
      response.should redirect_to("http://test.host/redirect_spec/somewhere")
    end
    
    it "a call to response.should redirect_to should fail if no redirect" do
      get 'action_with_no_redirect'
      lambda {
        response.redirect?.should be_true
      }.should fail
      lambda {
        response.should redirect_to("http://test.host/redirect_spec/somewhere")
      }.should fail_with("expected redirect to \"http://test.host/redirect_spec/somewhere\", got no redirect")
    end
  end
  
  describe "Given a controller spec running in #{mode} mode" do
    example_group = describe "A controller spec"
    # , :type => :controller do
    # integrate_views if mode == 'integration'
    it "a spec in a context without controller_name set should fail with a useful warning" do
      pending("need a new way to deal with examples that should_raise")
    # ,
    #   :should_raise => [
    #     Spec::Expectations::ExpectationNotMetError,
    #     /You have to declare the controller name in controller specs/
    #   ] do
    end
  end
  
end

['integration', 'isolation'].each do |mode|
  describe "A controller example running in #{mode} mode", :type => :controller do
    controller_name :controller_inheriting_from_application_controller
    integrate_views if mode == 'integration'
    
    it "should only have a before filter inherited from ApplicationController run once..." do
      controller.should_receive(:i_should_only_be_run_once).once
      get :action_with_inherited_before_filter
    end
  end
end

# # FIXME - not sure why this fails against 2.0.5, since generated controller
# # specs that use the implicit controller pass.
describe ControllerSpecController, :type => :controller do
  it "should use the controller passed to #describe" do
  end  
end

describe "A controller spec with controller_name set", :type => :controller do
  controller_name :controller_spec
  
  describe "nested" do
    it "should inherit the controller name" do
      get 'action_with_template'
      response.should be_success
    end
  end
end

module Spec
  module Rails
    module Example
      describe ControllerExampleGroup do
        it "should clear its name from the description" do
          group = describe("foo", :type => :controller) do
            $nested_group = describe("bar") do
            end
          end
          group.description.to_s.should == "foo"
          $nested_group.description.to_s.should == "foo bar"
        end
      end
    end
  end
end