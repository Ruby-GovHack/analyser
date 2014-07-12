require_relative '../models/site'
require_relative '../models/sparql_data_provider'
require_relative '../models/data_analyser'

class Seeds
  def initialize
    @provider = SparqlDataProvider.new('acorn-sat')
  end

  def seed_all
    Site.fetch(@provider) unless Site.count > 0
    DataAnalyser.fetch(@provider)
    "New monthly data count: #{MonthlyData.count}"
  end

  def seed_test
    Site.fetch(@provider) unless Site.count > 0
    DataAnalyser.fetch(@provider, "01-2000", "01-2011", 1-35.0, 150.5, -36.0, 147.2)
    "New monthly data count: #{MonthlyData.count}"
  end
end
