class CreatePowerSupplies < ActiveRecord::Migration[7.1]
  def change
    create_table :power_supplies do |t|
      t.string :model
      t.string :form_factor
      t.integer :wattage
      t.decimal :avg_efficiency
      t.decimal :avg_efficiency_5vsb
      t.decimal :vampire_power
      t.decimal :avg_pf
      t.decimal :avg_noise
      t.string :efficiency_rating
      t.string :noise_rating
      t.date :release_date
      t.string :manufacturer
      t.string :atx_version

      t.timestamps
    end
  end
end
