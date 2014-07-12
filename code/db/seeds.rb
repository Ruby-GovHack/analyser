require_relative '../models/site'
require_relative '../models/sparql_data_provider'
require_relative '../models/data_analyser'

provider = SparqlDataProvider.new('acorn-sat')
Site.fetch(provider)
DataAnalyser.fetch(provider, "01-1935", "01-1945", 1-35.0, 150.5, -36.0, 147.2)