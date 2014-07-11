require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Home' do
  it "displays the README" do
    get "/"
    expect(last_response.body).to include("RubyGovHackers API")
  end

end

describe 'API' do
  it "should return the set of sites" do
    get "/v1/sites/acorn-sat"
    expect(last_response.body).to include("069018")
  end

  it "should return monthly data for a geographic area" do
    get "/v1/timeseries/monthly/acorn-sat?max-temp&max-temp-std-dev&time=200809&north=-35.0&east=150.5&south=-36.0&west=147.2"
    expect(last_response.body).to include('{"id": "069018", "max-temp":20.02, "max-temp-std-dev": 5.11 }')
    expect(last_response.body).to include('{"id": "070351", "max-temp":18.48, "max-temp-std-dev": 3.95 }')
  end

end