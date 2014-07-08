#!/usr/bin/env ruby -I.

require 'locations'

loc = Locations.new
records = loc.count

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
