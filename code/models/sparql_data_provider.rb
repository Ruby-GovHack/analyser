class SparqlDataProvider

  ACORN_SAT_ENDPOINT = 'http://lab.environment.data.gov.au/sparql'
  SITE_URI = 'http://lab.environment.data.gov.au/def/acorn/site/Site'
  SUPPORTED_DATASETS = ['acorn-sat']

  attr_reader :site_uri

  def initialize(dataset)
    details = provider_details(dataset)
    @sparql = SPARQL::Client.new(details[:endpoint])
    @site_uri = RDF::URI(details[:site_uri])
  end

  def fetch(vars, patterns)
    @sparql.select(*vars).distinct.where(*patterns).each_solution
  end

  def self.validate_dataset(dataset)
    throw("Unknown dataset: #{dataset}. Supported datasets are #{SUPPORTED_DATASETS}") unless SUPPORTED_DATASETS.include? dataset
  end

  def provider_details(dataset)
    self.class.validate_dataset dataset
    case dataset
      when 'acorn-sat'
        {endpoint: ACORN_SAT_ENDPOINT, site_uri: SITE_URI}
    end
  end


end