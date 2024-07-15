class AddFavoriteToPsuPrice < ActiveRecord::Migration[7.1]
  def change
    add_column :psu_prices, :favorite, :boolean
  end
end
