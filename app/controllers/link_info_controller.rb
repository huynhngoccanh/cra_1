class LinkInfoController < ApplicationController
	include ApplicationHelper

  def index
  	@data = make_image_link(params[:url]) if params[:url]
  end
end
