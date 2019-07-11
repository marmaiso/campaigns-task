require 'spec_helper'

describe Campaigns::DiscrepanciesDetector do
  context 'when remote campaigns could be fetched' do
    let(:local_campaign1) do
      OpenStruct.new(id: 1,
                     job_id: 3,
                     status: 'active',
                     external_reference: 1,
                     ad_description: 'Ruby on Rails Developer')
    end
    let(:local_campaign2) do
      OpenStruct.new(id: 2,
                     job_id: 4,
                     status: 'active',
                     external_reference: 2,
                     ad_description: 'Frontend developer')

    end
    let(:local_campaign3) do
      OpenStruct.new(id: 3,
                     job_id: 5,
                     status: 'active',
                     external_reference: 3,
                     ad_description: 'Java developer')

    end
    let(:local_campaigns) { [local_campaign1, local_campaign2, local_campaign3] }
    let(:campaigns_info) do
      {
        'ads': [
          {
            'reference': '1',
            'status': 'disabled',
            'description': 'Rails Engineer'
          },
          {
            'reference': '2',
            'status': 'active',
            'description': 'Frontend developer'
          },
          {
            'reference': '3',
            'status': 'deleted',
            'description': 'Java developer'
          }]
      }
    end

    let(:discrepancies) do
      [
        {
          remote_reference: 1,
          discrepancies:
            [
              { status: { local: 'active', remote: 'disabled' } },
              {
                ad_description:
                { local: 'Ruby on Rails Developer', remote: 'Rails Engineer' }
              }
            ],
        },
        {
          remote_reference: 3,
          discrepancies: [ status: { local: 'active', remote: 'deleted' } ]
        }
      ]
    end

    before do
      allow(Campaigns::Fetcher).to receive(:call).and_return(JSON(campaigns_info))
      allow(Campaign).to receive(:find_in_batches).and_yield(local_campaigns)
    end

    it 'returns the discrepancies' do
      expect(Campaigns::DiscrepanciesDetector.call).to eq(discrepancies)
    end
  end

  context 'when campaigns could not be fetched' do
    let(:error) { { error: 'Could not get campaigns' } }

    before do
      allow(Campaigns::Fetcher).to receive(:call).and_return(error)
    end

    it 'returns an error' do
      expect(Campaigns::DiscrepanciesDetector.call).to eq([error])
    end
  end
end
