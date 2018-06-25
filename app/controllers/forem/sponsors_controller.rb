class Forem::SponsorsController < Forem::ApplicationController
	layout "sponsors"

  def show
  	@sponsor_logo =  SponsorLogo.friendly.find(params[:id])
  end

end
