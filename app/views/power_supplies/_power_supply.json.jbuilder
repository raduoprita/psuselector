json.extract! power_supply, :id, :model, :atx_version, :form_factor, :wattage, :avg_efficiency, :avg_efficiency_5vsb, :vampire_power, :avg_pf, :avg_noise, :efficiency_rating, :noise_rating, :release_date, :created_at, :updated_at
json.url power_supply_url(power_supply, format: :json)
