require 'spec_helper'

describe Campaigns::Fetcher do
  before do
    stub_request(:get, ENV['AD_SERVICE_API'])
      .to_return(status: status, body: response_body.to_json, headers: {})
  end

  context 'when the API works' do
    let(:status) { 200 }
    let(:response_body) do
      {
        'ads': [
          {
            'reference': '1',
            'status': 'enabled',
            'description': 'Description for campaign 11'
          },
          {
            'reference': '2',
            'status': 'disabled',
            'description': 'Description for campaign 12'
          }]
      }
    end

    it 'returns the information' do
      expect(Campaigns::Fetcher.call).to eq(response_body.deep_stringify_keys!)
    end
  end

  context 'when the API does not work' do
    let(:status) { 400 }
    let(:response_body) { { 'error': 'Request could not be processed' } }

    it 'returns an error' do
      expect(Campaigns::Fetcher.call).to eq({ error: 'Could not get campaigns' })
    end
  end
end
