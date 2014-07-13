require 'json'
require 'mongoid'

class MonthlyData
  include Mongoid::Document

  field :year, type: Integer
  field :month, type: Integer
  field :year_month, type: Integer
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

  def self.filter_all(site, start_time=nil, end_time=nil)
    start_time ||= '00-0000'
    end_time ||= '99-999999'
    start_month, start_year = start_time.split('-').map { |a| a.to_i }
    end_month, end_year = end_time.split('-').map { |a| a.to_i }
    result = {}
    MonthlyData.where(
        :site => site,
        :year_month.gte => start_year*100+start_month,
        :year_month.lte => end_year*100+end_month
    ).order_by(:year_month.asc).each { |d| result[d.year_month] = d }
    result
  end

  def self.in_date_range(month, year, start_time, end_time)
    start_month, start_year = start_time.split('-').map { |a| a.to_i }
    end_month, end_year = end_time.split('-').map { |a| a.to_i }
    (year >= start_year) && (year <= end_year) &&
        (year != start_year || month >= start_month) &&
        (year != end_year || month <= end_month)
  end


  def as_json(options = {})
    options[:vars] ||= ['high_max_temp', 'low_min_temp']
    options[:vars] << 'month'
    {:month => sprintf("%02d", month) + "-#{year}",
     :year_month => year_month,
     :high_max_temp => high_max_temp,
     :low_min_temp => low_min_temp,
     :max_highest_since => max_highest_since,
     :max_lowest_since => max_lowest_since,
     :max_ten_max => max_ten_max,
     :max_ten_min => max_ten_min,
     :max_moving_mean => max_moving_mean,
     :min_highest_since => min_highest_since,
     :min_lowest_since => min_lowest_since,
     :min_ten_max => min_ten_max,
     :min_ten_min => min_ten_min,
     :min_moving_mean => min_moving_mean}.select { |k, _|
      options[:vars] && (options[:vars].include? k.to_s) }

  end

end