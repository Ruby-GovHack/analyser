require 'json'

class MonthlyData
  include Mongoid::Document

  field :year, type: Integer
  field :month, type: Integer
  has_one :site
  index({ site: 1, year: 1, month: 1 }, { unique: true })


end