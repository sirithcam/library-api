class CreatePurchases < ActiveRecord::Migration[7.0]
  def change
    create_table :purchases do |t|
      t.integer :user_id
      t.integer :book_id
      t.string :currency
      t.string :status
      t.string :token
      t.string :payment_method

      t.timestamps
    end
  end
end
