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

  it "should return data for a specified month and geographic area" do
    get "/v1/timeseries/monthly/acorn-sat?max-temp=true&max-temp-std-dev=true&time=09-2008&north=-35.0&east=150.5&south=-36.0&west=147.2"
    expect(last_response.body).to include('{"id": "069018", "max-temp":20.02, "max-temp-std-dev": 5.11 }')
    expect(last_response.body).to include('{"id": "070351", "max-temp":18.48, "max-temp-std-dev": 3.95 }')
  end

  it "should return monthly time-series data for a site" do
    get "/v1/timeseries/monthly/acorn-sat?max-temp=true&start=08-2008&end=11-2008&site=072161"
    expect(last_response.body).to include('{"month":"08-2008", "max-temp":32.83}')
    expect(last_response.body).to include('{"month":"09-2008", "max-temp":32.83}')
    expect(last_response.body).to include('{"month":"10-2008", "max-temp":18.32}')
    expect(last_response.body).to include('{"month":"11-2008", "max-temp":25.34}')
    expect(last_response.body).not_to include('"month":"12-2008"')
  end

end