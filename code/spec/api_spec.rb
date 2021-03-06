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

  it 'should return data for a specified month' do
    get '/v1/timeseries/monthly/acorn-sat?high_max_temp=true&max-temp-std-dev=true&time=09-2008'
    expect(last_response.body).to include('"069018":{"200809":{"high_max_temp":29.2')
    expect(last_response.body).to include('"070351":{"200809":{"high_max_temp":25.9')
    expect(last_response.body).to include('"072161":{"200809":{"high_max_temp":17.5')
    expect(last_response.body).to include('"072150":{"200809":{"high_max_temp":29.0')
  end

  it 'should restrict data by geographic area"' do
    get '/v1/timeseries/monthly/acorn-sat?high_max_temp&low_min_temp&time=09-2008&north=-35.0&east=150.0&south=-36.0&west=147.2'
    expect(last_response.body).not_to include('"069018"')
    expect(last_response.body).to include('"070351":{"200809":{"high_max_temp":25.9,"low_min_temp":-5.7}}')
    expect(last_response.body).to include('"072161":{"200809":{"high_max_temp":17.5,"low_min_temp":-3.9}}')
    expect(last_response.body).to include('"072150":{"200809":{"high_max_temp":29.0,"low_min_temp":-2.6}}}')
  end

  context 'start time and end time specified' do
    it 'should return monthly time-series data for a site' do
      get '/v1/timeseries/monthly/acorn-sat?high_max_temp&start=08-2008&end=11-2008&site=072161'
      expect(last_response.body).to include('200808":{"high_max_temp":8.2')
      expect(last_response.body).to include('200809":{"high_max_temp":17.5')
      expect(last_response.body).to include('200810":{"high_max_temp":20.5')
      expect(last_response.body).to include('200811":{"high_max_temp":21.4')
      expect(last_response.body).not_to include('"200812"')
      expect(last_response.body).not_to include('"200807"')
    end
  end

  context 'a single time is specified' do
    it 'should return monthly time-series data for a site' do
      get '/v1/timeseries/monthly/acorn-sat?high_max_temp=true&time=08-2008&site=072161'
      expect(last_response.body).to include('{"high_max_temp":8.2')
      expect(last_response.body).not_to include('"month":"09-2008"')
      expect(last_response.body).not_to include('"month":"07-2008"')
    end
  end

  context 'time is not specified' do
    it 'should return all months for a site' do
      get '/v1/timeseries/monthly/acorn-sat?high_max_temp&site=072161'
      expect(last_response.body).to include('{"high_max_temp":24.0')
      expect(last_response.body).to include('{"high_max_temp":25.2')
    end
  end

  context 'only low min is specified' do
    it 'should not include other data' do
      get '/v1/timeseries/monthly/acorn-sat?low_min_temp&site=072161'
      expect(last_response.body).not_to include('"high_max_temp"')
      expect(last_response.body).to include('"low_min_temp"')
    end
  end
end