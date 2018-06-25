class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    object = params[:type].classify.constantize.find_by(id: params[:id])
    object.liked_by(current_user) if object.present?
    render json: { likes: Vote.where(votable: object).count }
  end
end
