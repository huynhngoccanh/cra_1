class FixColumnName < ActiveRecord::Migration
  def self.up
    rename_column :job_subscriptions, :plan_id, :job_plan_id
  end

  def self.down
    rename_column :job_subscriptions, :job_plan_id, :plan_id
  end
end
