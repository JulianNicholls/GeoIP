#!/usr/bin/env ruby -I. -w

# IP Address class, holds the address as dotted IP and numeric
class IPHolder
  attr_reader :parts, :numeric

  def initialize( input )
    if input.is_a? Fixnum
      @numeric = input
      @parts   = interpret_from_num( input )
    else
      @numeric = interpret_from_text( input )
    end
  end

  def dotted
    @parts.join '.'
  end

  def to_s
    "IP: #{dotted}, Numeric: #{numeric}"
  end

  private

  def interpret_from_text( input )
    sections = input.split( '.' ).map( &:to_i )

    if sections.size == 1
      @parts    = interpret_from_num( input.to_i )
      input.to_i
    else
      @parts = sections

      @parts.reduce( 0 ) { |a, e| a * 256 + e }
    end
  end

  def interpret_from_num( input )
    parts = []

    4.times do
      parts << (input % 256)
      input /= 256
    end

    parts.reverse
  end
end

if $PROGRAM_NAME == __FILE__
  ip1 = IPHolder.new( ARGV[0] )
  ip2 = ARGV[1] ? IPHolder.new( ARGV[1] ) : nil

  if ip2.nil?
    puts ip1
  else
    puts "#{ip1.dotted} - #{ip2.dotted}, #{ip1.numeric} - #{ip2.numeric}"
  end
end
