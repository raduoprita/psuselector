class CreatePsuPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :psu_prices do |t|
      t.string :model
      t.integer :price

      t.timestamps
    end
  end
end
