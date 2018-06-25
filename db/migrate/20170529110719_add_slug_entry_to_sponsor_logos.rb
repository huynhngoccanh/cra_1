class AddSlugEntryToSponsorLogos < ActiveRecord::Migration
  def change
  	SponsorLogo.find_each(&:save)
  end
end
