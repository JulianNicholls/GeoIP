require 'csv'

require 'veneer'

# Veneer over Mongo for the locations collection
class IPRanges < MongoVeneer
  @fields = %w(num_start, num_end, loc_id, ip_start, ip_end)

  def initialize
    super

    @coll = @db['ipranges']
  end
end
