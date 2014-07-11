require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Home' do
  it "displays the README" do
    get "/"
    expect(last_response.body).to include("RubyGovHackers API")
  end

end

describe 'API' do
  it "should return the set of sites" do
    get "/v1/acorn-sat/sites"
    expect(last_response.body).to include("069018")
  end

end