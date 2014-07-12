require 'json'

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
    start_month, start_year = start_time.split('-').map {|a| a.to_i}
    end_month,   end_year =   end_time.split('-').map {|a| a.to_i}
    MonthlyData.where(
        :site => site,
        :year_month.gte => start_year*100+start_month,
        :year_month.lte => end_year*100+end_month
    ).to_a
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