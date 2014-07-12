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

  it 'should return data for a specified month and geographic area"' do
    get '/v1/timeseries/monthly/acorn-sat?max-temp=true&max-temp-std-dev=true&time=09-2008&north=-35.0&east=150.5&south=-36.0&west=147.2'
    expect(last_response.body).to include('"069018":[{"month":"09-2008","high_max_temp":29.2}]')
    expect(last_response.body).to include('"070351":[{"month":"09-2008","high_max_temp":25.9}]')
  end

  context 'start time and end time specified' do
    it 'should return monthly time-series data for a site' do
      get '/v1/timeseries/monthly/acorn-sat?max-temp=true&start=08-2008&end=11-2008&site=072161'
      expect(last_response.body).to include('{"month":"08-2008","high_max_temp":8.2}')
      expect(last_response.body).to include('{"month":"09-2008","high_max_temp":17.5}')
      expect(last_response.body).to include('{"month":"10-2008","high_max_temp":20.5}')
      expect(last_response.body).to include('{"month":"11-2008","high_max_temp":21.4}')
      expect(last_response.body).not_to include('"month":"12-2008"')
      expect(last_response.body).not_to include('"month":"07-2008"')
    end
  end

  context 'a single time is specified' do
    it 'should return monthly time-series data for a site' do
      get '/v1/timeseries/monthly/acorn-sat?max-temp=true&time=08-2008&site=072161'
      expect(last_response.body).to include('{"month":"08-2008","high_max_temp":8.2}')
      expect(last_response.body).not_to include('"month":"09-2008"')
      expect(last_response.body).not_to include('"month":"07-2008"')
    end
  end

  context 'time is not specified' do
    it 'should return all months for a site' do
      get '/v1/timeseries/monthly/acorn-sat?max-temp=true&site=072161'
      expect(last_response.body).to include('{"month":"01-2000","high_max_temp":24.0}')
      expect(last_response.body).to include('{"month":"12-2010","high_max_temp":25.2}')
    end
  end

end