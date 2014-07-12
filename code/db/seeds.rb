require_relative '../models/site'
require_relative '../models/data_provider'

provider = DataProvider.new(provider_details(params[:dataset]))
Site.fetch(provider).to_json
