require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test "connects" do
      connect

      assert connection.present?
    end
  end
end
