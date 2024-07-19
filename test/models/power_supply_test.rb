require "test_helper"

class PowerSupplyTest < ActiveSupport::TestCase
  test 'fixtures loaded' do
    assert PowerSupply.find_by(model: 'MyString').present?
  end

  test "not valid without required fields" do
    power_supply = PowerSupply.new
    assert_not power_supply.valid?
    assert_equal [:model, :manufacturer, :atx_version, :wattage, :efficiency_rating],
      power_supply.errors.messages.keys
  end

  test "valid with proper fields" do
    power_supply = PowerSupply.new(
      manufacturer: 'Test',
      model: 'Test M',
      atx_version: 'ATX',
      wattage: '100',
      efficiency_rating: 'A'
    )
    assert power_supply.valid?
    assert_empty power_supply.errors
  end
end
