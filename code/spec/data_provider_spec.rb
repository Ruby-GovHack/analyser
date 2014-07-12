require 'rspec'

describe 'Providers' do

  let(:provider) {DataProvider.new('acorn-sat')}

  it 'should provide a sparql endpoint' do
    expect(provider.site_uri).to eq('http://lab.environment.data.gov.au/def/acorn/site/Site')
    site, _ = Site.fetch(provider).first
    #print site
    #print MonthlyData.fetch(provider, site).to_json
  end
end