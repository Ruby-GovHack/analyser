require 'rdf'
require 'linkeddata'
require 'sparql/client'

class Site
  include Mongoid::Document

  field :site_id, type: String
  field :label, type: String
  field :lat, type: Float
  field :long, type: Float

  def self.create_from_solution!(solution)
    Site.create!(
        site_id: id_from_uri(solution[:site]),
        label: label_from_variable(solution.label),
        lat: solution.to_hash[:lat].value.to_f,
        long: solution.to_hash[:long].value.to_f)
  end

  def self.label_from_variable(label_variable)
    label_variable.value.gsub(/\w+/) do |word|
      word.capitalize
    end
  end

  def self.id_from_uri(site_uri)
    site_uri.to_s.split('/').last
  end

  def self.fetch
    sparql = SPARQL::Client.new("http://lab.environment.data.gov.au/sparql")

    site_uri = RDF::URI("http://lab.environment.data.gov.au/def/acorn/site/Site")
    lat_uri = RDF::URI("http://www.w3.org/2003/01/geo/wgs84_pos#lat")
    long_uri = RDF::URI("http://www.w3.org/2003/01/geo/wgs84_pos#long")
    label_uri = RDF::URI("http://www.w3.org/2000/01/rdf-schema#label")
    patterns = [
        [:site, 'a', site_uri],
        [:site, lat_uri, :lat],
        [:site, long_uri, :long],
        [:site, label_uri, :label]
    ]
    query = sparql.select(:site, :lat, :long, :label).distinct.where(*patterns)

    query.each_solution.map do |solution|
      Site.create_from_solution!(solution)
    end
  end
end