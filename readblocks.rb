#!/usr/bin/env ruby -I.

require 'csv'
require 'pp'

require 'iptool'

class BlocksReader
  def initialize( filename = 'GeoLiteCity-Blocks.csv' )
    output = CSV.open( 'output.csv', 'wb' )

    CSV.foreach( filename ) do |row|
      next unless row.size > 1
      ip_start = IPConverter.new( row[0] )
      ip_end   = IPConverter.new( row[1] )
      row.push( ip_start.ip, ip_end.ip )
      output << row
    end
  end
end

BlocksReader.new
