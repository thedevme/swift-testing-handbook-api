class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases, id: :uuid do |t|
      t.string :email, null: false
      t.string :order_number, null: false
      t.string :product_id
      t.integer :price_cents
      t.datetime :purchased_at, null: false

      t.timestamps
    end
    add_index :purchases, :email
    add_index :purchases, :order_number, unique: true
  end
end
