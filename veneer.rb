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
    @cached = []
  end

  def count( opts = {} )
    flush_inserts

    return @coll.count( opts )
  end

  def insert( hash_or_array )
    @coll.insert hash_or_array
  end

  def drop
    @coll.drop
  end

  def find( selector = {}, opts = {} )
    @coll.find selector, opts
  end

  def build_from_csv( filename )
    records = 1

    File.open( filename ) do |file|
      print "Reading #{filename}... "
      lines = file.readlines

      puts "#{lines.size} Lines"

      lines.each do |line|
        insert_from_line( line.chomp.encode( 'UTF-8', invalid: :replace ) )

        print " #{records}... " if (records += 1) % 1000 == 0
        puts if records % 10000 == 0
      end
    end

    flush_inserts
  end

  protected

  # Insert a record from a line in the CSV file, ignoring lines with invalid
  # byte sequences.
  def insert_from_line( line )
    begin
      row = line.chomp.parse_csv
      @cached << record( row )
    rescue => e
      print '#'
    end

    flush_inserts if @cached.size >= 1000
  end

  def record( row )
    Hash[self.class.fields.zip row]
  end

  def flush_inserts
    insert( @cached ) if @cached.size > 0
    @cached = []
  end
end
