class AddPlanIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :plan_id, :string
  end
end
