class CreatePurchaseIntents < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_intents do |t|
      t.integer :user_id
      t.integer :book_id
      t.decimal :price
      t.string :currency
      t.string :payment_method

      t.timestamps
    end
  end
end
