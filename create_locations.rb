#!/usr/bin/env ruby -I.

require 'mongo'
require 'csv'

class Locations
  include Mongo

  FIELDS =  %w(loc_id country region city postcode latitude longitude metrocode areacode)

  def initialize
    @client = MongoClient.new
    @db = @client['GeoIP']
    @coll = @db['locations']
  end

  def size
    return @coll.count
  end

  def insert( hash )
    @coll.insert hash
  end

  def drop
    @coll.drop
  end

  def build_from_csv( file )
    count = 1

    File.open( file ) do |file|
      loop do
        line = file.gets

        break if line.nil?

        insert_from_line( line.chomp )

        print " #{count}... " if (count += 1) % 1000 == 0
        puts if count % 10000 == 0
      end
    end
  end

  private

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
    Hash[FIELDS.zip row]
  end
end

loc = Locations.new
records = loc.size

if records > 0
  print "Current: #{records}, reload? "

  response = ''

  loop do
    response = gets.chomp.upcase
    break if 'YN'.include? response
  end

  exit unless response == 'Y'

  loc.drop
end

loc.build_from_csv( 'GeoLiteCity-Location.csv' )
