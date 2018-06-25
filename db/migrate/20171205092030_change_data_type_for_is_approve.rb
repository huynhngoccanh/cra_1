class ChangeDataTypeForIsApprove < ActiveRecord::Migration
  def change
    remove_column :users, :is_approve
    add_column :users, :is_approve, :string, default: "Pending"
  end
end
