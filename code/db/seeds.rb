require_relative '../models/site'
require_relative '../models/data_provider'

provider = DataProvider.new('acorn-sat')
Site.fetch(provider)