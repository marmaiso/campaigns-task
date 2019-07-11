require './lib/services/campaigns/fetcher.rb'
require './lib/concerns/callable.rb'
require './lib/models/campaign.rb'

class Campaigns::DiscrepanciesDetector
  include Callable

  ATTRIBUTES_MAPPING = { status: 'status', ad_description: 'description' }

  def initialize
    @campaigns_info = Campaigns::Fetcher.call
    @discrepancies = []
  end

  def call
    if @campaigns_info['ads']
      compare_data
    else
      couldnot_process
    end
  end

  private

  def compare_data
    Campaign.find_in_batches do |local_campaigns|
      local_campaigns.map do |local_campaign|
        remote_campaign = find_remote_campaign(local_campaign)
        result = find_discrepancies(local_campaign, remote_campaign)
        @discrepancies << result unless result[:discrepancies].blank?
      end
    end

    @discrepancies
  end

  def find_remote_campaign(local_campaign)
    JSON(@campaigns_info)['ads'].find do |info|
      info['reference'].to_i == local_campaign.external_reference
    end
  end

  def find_discrepancies(local_campaign, remote_campaign)
    {}.tap do |info|
      info.merge!(remote_reference: local_campaign.external_reference, discrepancies: [])

      ATTRIBUTES_MAPPING.each do |local_key, remote_key|
        local_value = local_campaign.send(local_key)
        remote_value = remote_campaign[remote_key]

        if local_value != remote_value
          discrepancies = { local_key => { remote: remote_value, local: local_value } }
          info[:discrepancies] << discrepancies
        end
      end
    end
  end

  def couldnot_process
    [@campaigns_info]
  end
end
