require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../models/site'

describe Site do

  let(:site) { Site.new }

  it 'should fetch sites from the SPARQL endpoint' do
    sites = Site.fetch
    #print sites.to_json
    _, site = sites.first
    expect(sites.size).to be(112)
    expect(site.site_id).to eq("023090")
    expect(site.label).to eq("Adelaide (Kent Town)")
    expect(site.lat).to be_within(0.001).of(-34.921)
    expect(site.long).to be_within(0.001).of(138.622)
    expect(site.to_json).to eq("{\"label\":\"Adelaide (Kent Town)\",\"lat\":-34.921,\"long\":138.622}")
  end

end