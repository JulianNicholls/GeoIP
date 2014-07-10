#!/usr/bin/env ruby -I. -w

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

  def interpret_from_num( input )
    parts = []

    4.times do
      parts << (input % 256)
      input /= 256
    end

    parts.reverse
  end

  def interpret_from_text( input )
    sections = input.split '.'

    if sections.size == 1
      @parts    = interpret_from_num( input.to_i )
      input.to_i
    else
      @parts    = sections.map( &:to_i )
      total     = 0

      @parts.each do |part|
        total *= 256
        total += part
      end

      total
    end
  end

  def dotted
    @parts.join '.'
  end

  def to_s
    "IP: #{dotted}, Numeric: #{numeric}"
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
