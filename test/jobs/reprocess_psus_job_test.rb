require "test_helper"

class ReprocessPsusJobTest < ActiveJob::TestCase
  test "PSUs are loaded" do
    perform_enqueued_jobs do
      ReprocessPsusJob.perform_later
    end
    assert PowerSupply.first.present?
  end
end
