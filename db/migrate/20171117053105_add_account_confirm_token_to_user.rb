class AddAccountConfirmTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :account_confirm_token, :string
    add_column :users, :email_confirmed, :boolean, :default => false
    add_column :users, :login_stripe_id, :string
    add_column :users, :login_stripe_card_holder, :string
    add_column :users, :login_stripe_postal_code, :string
  end
end
