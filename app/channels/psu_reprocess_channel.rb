class PsuReprocessChannel < ApplicationCable::Channel
  def subscribed
    stream_from "all"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
