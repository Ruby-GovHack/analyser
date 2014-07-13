require_relative '../models/site'
require_relative '../models/sparql_data_provider'
require_relative '../models/data_analyser'

class Seeds
  def initialize
    @provider = SparqlDataProvider.new('acorn-sat')
  end

  def seed_all
    Site.fetch(@provider) unless Site.count > 0

    more_to_fetch = true
    while more_to_fetch
      more_to_fetch = DataAnalyser.fetch(@provider, 10)
      puts "#{start = Time.now ; GC.start ; Time.now - start} GC time"
    end
    "New monthly data count: #{MonthlyData.count}"
  end

  def seed_test
    Site.fetch(@provider) unless Site.count > 0
    DataAnalyser.fetch(@provider, 4, "01-2000", "01-2011", 1-35.0, 150.5, -36.0, 147.2)
    "New monthly data count: #{MonthlyData.count}"
  end

  def drop
    Site.delete_all
    MonthlyData.delete_all
  end

end
