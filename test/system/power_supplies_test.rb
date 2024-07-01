require "application_system_test_case"

class PowerSuppliesTest < ApplicationSystemTestCase
  setup do
    @power_supply = power_supplies(:one)
  end

  test "visiting the index" do
    visit power_supplies_url
    assert_selector "h1", text: "Power supplies"
  end

  test "should create power supply" do
    visit power_supplies_url
    click_on "New power supply"

    fill_in "Atx version", with: @power_supply.atx_version
    fill_in "Avg efficiency", with: @power_supply.avg_efficiency
    fill_in "Avg efficiency 5vsb", with: @power_supply.avg_efficiency_5vsb
    fill_in "Avg noise", with: @power_supply.avg_noise
    fill_in "Avg pf", with: @power_supply.avg_pf
    fill_in "Efficiency rating", with: @power_supply.efficiency_rating
    fill_in "Form factor", with: @power_supply.form_factor
    fill_in "Model", with: @power_supply.model
    fill_in "Noise rating", with: @power_supply.noise_rating
    fill_in "Release date", with: @power_supply.release_date
    fill_in "Vampire power", with: @power_supply.vampire_power
    fill_in "Wattage", with: @power_supply.wattage
    click_on "Create Power supply"

    assert_text "Power supply was successfully created"
    click_on "Back"
  end

  test "should update Power supply" do
    visit power_supply_url(@power_supply)
    click_on "Edit this power supply", match: :first

    fill_in "Atx version", with: @power_supply.atx_version
    fill_in "Avg efficiency", with: @power_supply.avg_efficiency
    fill_in "Avg efficiency 5vsb", with: @power_supply.avg_efficiency_5vsb
    fill_in "Avg noise", with: @power_supply.avg_noise
    fill_in "Avg pf", with: @power_supply.avg_pf
    fill_in "Efficiency rating", with: @power_supply.efficiency_rating
    fill_in "Form factor", with: @power_supply.form_factor
    fill_in "Model", with: @power_supply.model
    fill_in "Noise rating", with: @power_supply.noise_rating
    fill_in "Release date", with: @power_supply.release_date
    fill_in "Vampire power", with: @power_supply.vampire_power
    fill_in "Wattage", with: @power_supply.wattage
    click_on "Update Power supply"

    assert_text "Power supply was successfully updated"
    click_on "Back"
  end

  test "should destroy Power supply" do
    visit power_supply_url(@power_supply)
    click_on "Destroy this power supply", match: :first

    assert_text "Power supply was successfully destroyed"
  end
end
