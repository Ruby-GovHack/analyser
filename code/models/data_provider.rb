class DataProvider

  def initialize(endpoint, base)
    @sparql = SPARQL::Client.new(endpoint)
    @site_uri = RDF::URI(base)
  end

  def fetch(vars, patterns)
    @sparql.select(*vars).distinct.where(*patterns).each_solution
  end

  attr_reader :site_uri
end