require "test_helper"

class PsuReprocessChannelTest < ActionCable::Channel::TestCase
  test "subscribes" do
    subscribe
    assert subscription.confirmed?
    assert_equal 'all', subscription.streams[0]
  end
end
