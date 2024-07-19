require "test_helper"

class ReprocessPsusJobTest < ActiveJob::TestCase
  test "Only getting the required manufacturer" do
    PowerSupply.delete_all
    perform_enqueued_jobs do
      ReprocessPsusJob.perform_later(manufacturer: 'ASUS')
    end
    assert PowerSupply.where(manufacturer: 'ASUS').first.present?
    assert PowerSupply.first.manufacturer == 'ASUS'
    assert_nil PowerSupply.where(manufacturer: 'NZXT').first
  end
end
