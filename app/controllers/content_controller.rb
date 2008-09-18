class ContentController < ApplicationController
  def index
    redirect_to :controller=>:home if current_user
  end
end