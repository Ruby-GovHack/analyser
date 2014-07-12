class DataProvider

  def initialize(details)
    @sparql = SPARQL::Client.new(details[:endpoint])
    @site_uri = RDF::URI(details[:site_uri])
  end

  def fetch(vars, patterns)
    @sparql.select(*vars).distinct.where(*patterns).each_solution
  end

  attr_reader :site_uri
end