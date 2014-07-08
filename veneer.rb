require 'mongo'

# Veneer over Mongo for the GeoIP collections
class MongoVeneer
  include Mongo

  @fields = []

  class << self
    attr_reader :fields
  end

  def initialize
    @client = MongoClient.new
    @db     = @client['GeoIP']
  end

  def count( opts = {} )
    return @coll.count( opts )
  end

  def insert( hash )
    @coll.insert hash
  end

  def drop
    @coll.drop
  end

  def build_from_csv( file )
    records = 1

    File.open( file ) do |file|
      loop do
        line = file.gets

        break if line.nil?

        insert_from_line( line.chomp )

        print " #{records}... " if (records += 1) % 1000 == 0
        puts if records % 10000 == 0
      end
    end
  end

  protected

  # Insert a record from a line in the CSV file, ignoring lines with invalid
  # byte sequences.
  def insert_from_line( line )
    begin
      row = line.chomp.parse_csv
      insert record( row )
    rescue => e
      print '#'
    end
  end

  def record( row )
    Hash[self.class.fields.zip row]
  end
end
