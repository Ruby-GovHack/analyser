require 'spec_helper'
require_relative '../models/monthly_data'

describe MonthlyData do

  let(:data) { MonthlyData.new }

  it 'should fetch data from mongoid' do
    site = Site.all_as_hash['072161']
    data = MonthlyData.filter_all(site, '08-2008', '08-2008').to_json
    expect(data).to eq('[{"month":"08-2008","high_max_temp":8.2}]')
  end
end