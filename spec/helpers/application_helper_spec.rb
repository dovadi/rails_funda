require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
include AuthenticatedTestHelper

describe ApplicationHelper do
  before do
    @user = mock_user
  end

  describe "Generating flash messages" do 
    it "should generate notice" do
      flash[:notice] = "Test notice"
      flash_helper.should have_tag("div[class='notice']")
    end
    it "should generate error" do
      flash[:error] = "Test error"
      flash_helper.should have_tag("div[class='error']")
    end
    it "should generate success" do
      flash[:success] = "Real success"
      flash_helper.should have_tag("div[class='success']")
    end
  end
end