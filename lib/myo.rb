require 'em-websocket-client'
require 'json'
require 'ostruct'

require 'myo/version'
require 'myo/client'

module Myo
  MYO_API_VERSION = 3
  SOCKET_URL = "ws://127.0.0.1:10138/myo/#{MYO_API_VERSION}"

  # Define event handler for each Myo armband
  def self.connect
    client = Client.new(SOCKET_URL)
    yield(client)
    client.start
  end
end
