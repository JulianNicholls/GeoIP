require 'csv'

require 'veneer'

# Veneer over Mongo for the locations collection
class IPRanges < MongoVeneer
  @fields = %w(num_start num_end loc_id ip_start ip_end)

  def initialize
    super

    @coll = @db['ipranges']
  end

  protected

  def record( row )
    record = super

    record['num_start'] = record['num_start'].to_i
    record['num_end'] = record['num_end'].to_i
    record['loc_id'] = record['loc_id'].to_i

    record
  end
end
