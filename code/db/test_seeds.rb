require_relative '../models/site'
require_relative '../models/sparql_data_provider'
require_relative '../models/data_analyser'

provider = SparqlDataProvider.new('acorn-sat')
Site.fetch(provider)
#DataAnalyser.fetch(provider)