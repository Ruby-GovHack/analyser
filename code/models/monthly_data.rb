require 'json'

class MonthlyData
  include Mongoid::Document

  field :year, type: Integer
  field :month, type: Integer
  field :high_max_temp, type: Float
  field :low_min_temp, type: Float
  field :max_highest_since, type: Integer
  field :max_lowest_since, type: Integer
  field :max_ten_max, type: Float
  field :max_ten_min, type: Float
  field :max_moving_mean, type: Float
  field :min_highest_since, type: Integer
  field :min_lowest_since, type: Integer
  field :min_ten_max, type: Float
  field :min_ten_min, type: Float
  field :min_moving_mean, type: Float
  belongs_to :site
  #index({ site: 1, year: 1, month: 1 }, { unique: true })

  def self.create_from_solution!(solution)
    MonthlyData.create!(
        year: id_from_uri(solution[:year]),
        month: id_from_uri(solution[:month]),
        high_max_temp: solution[:max].to_f)
  end

  def self.label_from_variable(label_variable)
    label_variable.to_s.gsub(/\w+/) do |word|
      word.capitalize
    end
  end

  def self.id_from_uri(site_uri)
    site_uri.to_s.split('/').last
  end

  def self.fetch(provider, site_id, start_month=nil, end_month=nil)
    start_month ||= '00-0000'
    end_month ||= '99-999999'
    time_series = 'http://lab.environment.data.gov.au/def/acorn/time-series/'
    acorn_sat   = 'http://lab.environment.data.gov.au/def/acorn/sat/'

    max_temp = RDF::URI(time_series + 'maxTemperatureMax')
    station  = RDF::URI('http://lab.environment.data.gov.au/data/acorn/climate/slice/station/' + site_id)
    subslice = RDF::URI('http://purl.org/linked-data/cube#subSlice')
    acorn_year  = RDF::URI(acorn_sat + 'year')
    acorn_month = RDF::URI(acorn_sat + 'month')

    vars = [:max, :year, :month]
    patterns = [
        [station,    subslice,   :sliceyear],
        [:sliceyear, subslice,   :yearmonth],
        [:yearmonth, acorn_year, :year],
        [:yearmonth, acorn_month,:month],
        [:yearmonth, max_temp,   :max]
    ]

    result = []
    provider.fetch(vars, patterns).each do |solution|
      year = id_from_uri(solution[:year]).to_i
      month = id_from_uri(solution[:month]).to_i
      result << MonthlyData.create_from_solution!(solution) if in_date_range(month, year, start_month, end_month)
    end
    result
  end

  def self.in_date_range(month, year, start_time, end_time)
    start_month, start_year = start_time.split('-').map {|a| a.to_i}
    end_month,   end_year =   end_time.split('-').map {|a| a.to_i}
    (year >= start_year) && (year <= end_year) &&
        (year != start_year || month >= start_month) &&
        (year != end_year || month <= end_month)
  end


  def as_json(options={})
    {:month => sprintf("%02d", month) + "-#{year}", :high_max_temp => high_max_temp}
  end

end