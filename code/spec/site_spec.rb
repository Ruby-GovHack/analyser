require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../models/site'

describe Site do

  let(:site) { Site.new }

  it 'gets turned into json' do
    expect(site.to_json).to eq("{\"site_id\":null,\"label\":null,\"lat\":null,\"long\":null}")
  end

  it 'should fetch sites from the SPARQL endpoint' do
    sites = Site.fetch
    #print sites.to_json
    expect(sites.size).to be(112)
    expect(sites.first.site_id).to eq("023090")
    expect(sites.first.label).to eq("Adelaide (Kent Town)")
    expect(sites.first.lat).to be_within(0.001).of(-34.921)
    expect(sites.first.long).to be_within(0.001).of(138.622)
    expect(sites.first.to_json).to eq("{\"site_id\":\"023090\",\"label\":\"Adelaide (Kent Town)\",\"lat\":-34.921,\"long\":138.622}")
  end

end