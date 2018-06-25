class AddIsApprovedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_approve, :boolean, default: false
  end
end
