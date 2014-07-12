require 'spec_helper'
require 'rspec'
require 'sparql/client'
require_relative '../models/site'
require_relative '../models/data_provider'

describe Site do

  let(:site) { Site.new }

  before(:each) do
    @provider = double(DataProvider,
                       fetch: [{:site => 'bla/023090', :label => 'Adelaide (Kent Town)',
                                :lat => double(value: -34.921), :long => double(value: 138.622)}],
                       site_uri: 'http://lab.environment.data.gov.au/def/acorn/site/Site'
    )
  end

  it 'should fetch sites from the SPARQL endpoint' do
    sites = Site.fetch(@provider)
    #print sites.to_json
    _, site = sites.first
    expect(sites.size).to be(1)
    expect(site.site_id).to eq('023090')
    expect(site.label).to eq('Adelaide (Kent Town)')
    expect(site.lat).to be_within(0.001).of(-34.921)
    expect(site.long).to be_within(0.001).of(138.622)
    expect(site.to_json).to eq('{"label":"Adelaide (Kent Town)","lat":-34.921,"long":138.622}')
  end

end