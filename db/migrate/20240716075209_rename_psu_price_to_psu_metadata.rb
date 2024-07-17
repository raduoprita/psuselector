class RenamePsuPriceToPsuMetadata < ActiveRecord::Migration[7.1]
  def change
    rename_table :psu_prices, :psu_metadata
  end
end
