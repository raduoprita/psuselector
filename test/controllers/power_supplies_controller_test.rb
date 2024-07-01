require "test_helper"

class PowerSuppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @power_supply = power_supplies(:one)
  end

  test "should get index" do
    get power_supplies_url
    assert_response :success
  end

  test "should get new" do
    get new_power_supply_url
    assert_response :success
  end

  test "should create power_supply" do
    assert_difference("PowerSupply.count") do
      post power_supplies_url, params: { power_supply: { atx_version: @power_supply.atx_version, avg_efficiency: @power_supply.avg_efficiency, avg_efficiency_5vsb: @power_supply.avg_efficiency_5vsb, avg_noise: @power_supply.avg_noise, avg_pf: @power_supply.avg_pf, efficiency_rating: @power_supply.efficiency_rating, form_factor: @power_supply.form_factor, model: @power_supply.model, noise_rating: @power_supply.noise_rating, release_date: @power_supply.release_date, vampire_power: @power_supply.vampire_power, wattage: @power_supply.wattage } }
    end

    assert_redirected_to power_supply_url(PowerSupply.last)
  end

  test "should show power_supply" do
    get power_supply_url(@power_supply)
    assert_response :success
  end

  test "should get edit" do
    get edit_power_supply_url(@power_supply)
    assert_response :success
  end

  test "should update power_supply" do
    patch power_supply_url(@power_supply), params: { power_supply: { atx_version: @power_supply.atx_version, avg_efficiency: @power_supply.avg_efficiency, avg_efficiency_5vsb: @power_supply.avg_efficiency_5vsb, avg_noise: @power_supply.avg_noise, avg_pf: @power_supply.avg_pf, efficiency_rating: @power_supply.efficiency_rating, form_factor: @power_supply.form_factor, model: @power_supply.model, noise_rating: @power_supply.noise_rating, release_date: @power_supply.release_date, vampire_power: @power_supply.vampire_power, wattage: @power_supply.wattage } }
    assert_redirected_to power_supply_url(@power_supply)
  end

  test "should destroy power_supply" do
    assert_difference("PowerSupply.count", -1) do
      delete power_supply_url(@power_supply)
    end

    assert_redirected_to power_supplies_url
  end
end
