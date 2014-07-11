require 'mongo'

# Veneer over Mongo for the GeoIP collections
class MongoVeneer
  include Mongo

  @fields = []

  CACHE_SIZE  = 1_000
  REPORT_SIZE = 1_000

  class << self
    attr_reader :fields
  end

  def initialize
    @client = MongoClient.new
    @db     = @client['GeoIP']
    @cached = []
  end

  def find( selector = {}, opts = {} )
    flush_inserts

    @coll.find selector, opts
  end

  def find_one( selector = {}, opts = {} )
    flush_inserts

    @coll.find_one selector, opts
  end

  def count( opts = {} )
    flush_inserts

    @coll.count( opts )
  end

  def insert( hash_or_array )
    @coll.insert hash_or_array
  end

  def drop
    @coll.drop
  end

  # The whole CSV file is read first
  def build_from_csv( filename )
    File.open( filename ) do |file|
      print "Reading #{filename}... "

      insert_from_lines( file.readlines )
    end

    flush_inserts
  end

  protected

  # Work through the passed CSV lines. Each line is (re-)encoded to UTF-8,
  # replacing illegal characters, before CSV parsing.
  def insert_from_lines( lines )
    puts "Inserting #{lines.size} Lines"

    records = 0

    lines.each do |line|
      insert_from_line( line.chomp.encode( 'UTF-8', invalid: :replace ) )

      print " #{records}... " if (records += 1) % REPORT_SIZE == 0
      puts if records % (REPORT_SIZE * 10) == 0
    end
  end

  # Insert a record from a line in the CSV file, ignoring lines with invalid
  # byte sequences. It is *probably* superfluous now (See above)
  def insert_from_line( line )
    begin
      row = line.chomp.parse_csv
      @cached << record( row )
    rescue
      print '#'
    end

    flush_inserts if @cached.size >= CACHE_SIZE
  end

  def record( row )
    Hash[self.class.fields.zip row]
  end

  def flush_inserts
    insert( @cached ) if @cached.size > 0
    @cached = []
  end
end
