require 'rspec'

describe 'Providers' do

  let(:provider) {SparqlDataProvider.new('acorn-sat')}

  it 'should provide a site uri' do
    expect(provider.site_uri).to eq('http://lab.environment.data.gov.au/def/acorn/site/Site')
  end
end