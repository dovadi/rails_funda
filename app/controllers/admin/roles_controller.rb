class Admin::RolesController < ApplicationController
  layout 'streamlined'
  acts_as_streamlined
  before_filter :login_required
end
