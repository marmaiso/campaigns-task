require 'net/http'

class Campaigns::Fetcher
  include Callable

  attr_reader :campaigns_info

  CAMPAIGNS_EXTERNAL_API = ENV['AD_SERVICE_API']

  def call
    begin
      uri = URI(CAMPAIGNS_EXTERNAL_API)
      response = Net::HTTP.get(uri)
      JSON(response)
    rescue JSON::ParserError, SocketError => e
      fail()

    end
  end
end

# Fetcher.call(params)
