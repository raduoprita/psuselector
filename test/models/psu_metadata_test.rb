require "test_helper"

class PsuMetadataTest < ActiveSupport::TestCase
  test "metadata creates on PSU create" do
    @psu = PowerSupply.create(
      manufacturer: 'Test Manufacturer',
      model: 'Test Model',
      atx_version: 'ATX',
      wattage: '100',
      efficiency_rating: 'GOLD'
    )

    assert @psu.psu_metadata.present?
    assert_equal 'Test Model', @psu.psu_metadata.model
  end

  test 'fixtures loaded' do
    assert PsuMetadata.find_by(model: 'MyString').present?
  end
end
