class AddSlugToSponsorLogos < ActiveRecord::Migration
  def change
    add_column :sponsor_logos, :slug, :string
    add_index :sponsor_logos, :slug, unique: true
  end
end
