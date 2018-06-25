class AddUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :web_url, :string
  end
end
