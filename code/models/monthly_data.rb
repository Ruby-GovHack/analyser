require 'json'

class MonthlyData
  include Mongoid::Document

  field :year, type: Integer
  field :month, type: Integer
  field :high_max_temp, type: Float
  has_one :site
  index({ site: 1, year: 1, month: 1 }, { unique: true })

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

  def self.fetch(provider, site_id, start_month='00-0000', end_month='99-999999')
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

    start_month, start_year = start_month.split('-').map {|a| a.to_i}
      end_month,   end_year =   end_month.split('-').map {|a| a.to_i}
    result = []
    provider.fetch(vars, patterns).each do |solution|
      year = id_from_uri(solution[:year]).to_i
      month = id_from_uri(solution[:month]).to_i
      result << MonthlyData.create_from_solution!(solution) unless
          (year < start_year) || (year > end_year) ||
          (year == start_year && month < start_month) ||
          (year == end_year && month > end_month)
    end
    result
  end


  def as_json(options={})
    {:month => sprintf("%02d", month) + "-#{year}", :high_max_temp => high_max_temp}
  end

end