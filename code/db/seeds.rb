require_relative '../models/site'
require_relative '../models/data_provider'
require_relative '../models/data_analyser'

provider = DataProvider.new('acorn-sat')
Site.fetch(provider)
DataAnalyser.fetch(provider)