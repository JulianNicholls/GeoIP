require 'csv'

require 'veneer'

# Veneer over Mongo for the locations collection
class Locations < MongoVeneer
  @fields = %w(loc_id country region city postcode lat long metrocode areacode)

  def initialize
    super

    @coll = @db['locations']
  end

  protected

  def record( row )
    @record = super

    @record['loc_id'] = @record['loc_id'].to_i

    convert_lat_long

    @record.delete_if { |_, v| v.nil? }

    @record
  end

  private

  def convert_lat_long
    @record['lat_long'] = [@record['lat'].to_f, @record['long'].to_f]

    @record.delete 'lat'
    @record.delete 'long'
  end
end
