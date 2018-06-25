class AddSubscriptionIdToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :subscription_id, :string
  end
end
