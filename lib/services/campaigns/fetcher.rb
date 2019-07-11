require 'net/http'
require './lib/concerns/callable.rb'

module Campaigns
  class Fetcher
    include Callable

    def call
      response = campaigns
      response.kind_of?(Net::HTTPSuccess) ? JSON(response.body) : error_response
    end

    private

    def campaigns
      uri = URI(ENV['AD_SERVICE_API'])
      Net::HTTP.get_response(uri)
    end

    def error_response
      { error: 'Could not get campaigns' }
    end
  end
end
