require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../models/example_model'

describe 'Home' do
  it "displays the README" do
    get "/"
    expect(last_response.body).to include("RubyGovHackers API")
  end

end

describe 'API' do
  describe "Example routes" do

    before :each do
      @e1 = ExampleModel.create!(id: 1, name: "First example")
      @e2 = ExampleModel.create!(id: 2, name: "Second example")
    end

    describe "/examples" do
      it "returns JSON representing all examples" do
        get '/examples'
        expect(last_response.body).to eq([@e1, @e2].to_json)
      end
    end

  end
end