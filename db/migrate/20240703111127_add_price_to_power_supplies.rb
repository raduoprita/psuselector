class AddPriceToPowerSupplies < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        add_column :power_supplies, :price, :integer
      end
      dir.down do
        remove_column :power_supplies, :price
      end
    end
  end
end
