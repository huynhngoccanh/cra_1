class AddContentToSponsorLogos < ActiveRecord::Migration
  def change
    add_column :sponsor_logos, :content, :text
  end
end
