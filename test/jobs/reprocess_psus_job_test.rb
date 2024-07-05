require "test_helper"

class ReprocessPsusJobTest < ActiveJob::TestCase
  # old test that loads too much data
  # test "PSUs are loaded" do
  #   perform_enqueued_jobs do
  #     ReprocessPsusJob.perform_later
  #   end
  #   assert PowerSupply.first.present?
  # end

  test "Only getting the required manufacturer" do
    PowerSupply.delete_all
    perform_enqueued_jobs do
      ReprocessPsusJob.perform_later(manufacturer: 'ASUS')
    end
    assert PowerSupply.where(manufacturer: 'ASUS').count == 2
    assert PowerSupply.first.manufacturer == 'ASUS'
    assert PowerSupply.where(manufacturer: 'NZXT').first.nil?
  end
end
