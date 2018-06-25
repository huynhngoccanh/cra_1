class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :invoice_id
      t.string :currency
      t.string :amount
      t.date :start_date
      t.date :end_date
      t.string :customer_id
      t.boolean :pay_status

      t.timestamps null: false
    end
  end
end
