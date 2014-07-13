require_relative '../models/site'
require_relative '../models/sparql_data_provider'
require_relative '../models/data_analyser'

class Seeds
  def initialize
    @provider = SparqlDataProvider.new('acorn-sat')
  end

  def seed_all
    Site.fetch(@provider) unless Site.count > 0

    sites = Site.all_as_hash
    ten_sites = Hash.new
    while !sites.empty?
      10.times do
        if sites.empty?
          break
        end
        site_id, site = sites.first
        ten_sites[site_id] = site
        sites.delete(site_id)
      end
      DataAnalyser.monthly_fetch_analyse(@provider, ten_sites)
      puts "#{start = Time.now ; GC.start ; Time.now - start} GC time"
      ten_sites.clear
    end
    "New monthly data count: #{MonthlyData.count}"
  end

  def seed_test
    Site.fetch(@provider) unless Site.count > 0
    sites = Site.all_as_hash.select { |site_id, site| site.in_bounding_box(1-35.0, 150.5, -36.0, 147.2) }
    DataAnalyser.monthly_fetch_analyse(@provider, sites, "01-2000", "01-2011")
    "New monthly data count: #{MonthlyData.count}"
  end

  def drop
    Site.delete_all
    MonthlyData.delete_all
  end

end
