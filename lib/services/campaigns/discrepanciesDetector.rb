class Campaigns::DiscrepanciesDetector
  include Callable

  def initialize
    @campaigns_info = Fetcher.call
  end

  def call
    if @campaigns_info

    else
    end
    uri = URI(CAMPAIGNS_EXTERNAL_API)
    response = Net::HTTP.get(uri)
    @campaigns_info = JSON(response)
  end
end
