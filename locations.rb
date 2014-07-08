require 'csv'

require 'veneer'

# Veneer over Mongo for the locations collection
class Locations < MongoVeneer
  @fields = %w(loc_id country region city postcode latitude longitude metrocode areacode)

  def initialize
    super

    @coll = @db['locations']
  end
end
