#!/usr/bin/env ruby -I.

require 'pp'

require 'locations'
require 'ipranges'
require 'ipholder'

class Fixnum
  def with_commas
    # Work through, finding...
    # Three digit sections, preceded and followed by at least one digit and...
    # Replace with the digits followed by a comma

    self.to_s.gsub( /(\d)(?=(\d{3})+(?!\d))/, '\\1,' )
  end
end

class GeoIPManager
  def initialize
    @loc = Locations.new
    @ips = IPRanges.new
  end

  def manage
    loop do
      show_record_counts
      print menu
      option = gets.chomp

      case option[0].downcase
      when 'x' then break

      when 'l' then load_locations
      when 'i' then load_ips
      when 'c' then check_ip
      end
    end
  end

  private

  def show_record_counts
    printf "\nIP Ranges: %9s\n", @ips.count.with_commas
    printf "Locations: %9s\n", @loc.count.with_commas
  end

  def load_locations
    @loc.drop
    @loc.build_from_csv( 'GeoLiteCity-Location.csv' )
  end

  def load_ips
    @ips.drop
    @ips.build_from_csv( 'ips.csv' )
  end

  def check_ip
    print "\nEnter IP as x.x.x.x or Numeric: "
    response = gets.chomp
    ip = IPHolder.new( response )
    puts "\nChecking #{ip}"

    crit = { num_start: {'$lte' => ip.numeric}, num_end: {'$gte' => ip.numeric} }
    ips  = @ips.find( crit ).to_a

    case ips.size
    when 0  then puts "No IP Range found"

    when 1  then
      addr = ips[0]
      puts ip_data( addr )

      locs = @loc.find( { loc_id: addr['loc_id'] } ).to_a

      if locs.size > 0
        puts loc_data( locs[0] )
      else
        puts "No Location Found"
      end
    else
      puts "WEIRD!"
      pp ips
    end
  end

  def menu
    %{
  (L)oad Locations.
  Load (I)Ps.
  (C)heck an IP.

  E(x)it

Select: }
  end

  def ip_data( ip )
    num_s, num_e = ip['num_start'], ip['num_end']
    %{
Range:    #{num_s.with_commas} - #{num_e.with_commas}
IP:       #{ip['ip_start']} - #{ip['ip_end']} (#{(num_e - num_s + 1).with_commas} Addressses)
Location: #{ip['loc_id']}
    }
  end

  def loc_data( loc )
    region    = loc.fetch( 'region', '' ).empty? ? '' : ", Region: #{loc['region']}"
    city      = loc.fetch( 'city', '' ).empty? ? '' : ", City: #{loc['city']}"
    postcode  = loc.fetch( 'postcode', '' ).empty? ? '' : "Postcode: #{loc['postcode']}"
    metrocode = loc.fetch( 'metrocode', '' ).empty? ? '' : ", Metro: #{loc['metrocode']}"
    areacode  = loc.fetch( 'areacode', '' ).empty? ? '' : ", Tel: #{loc['areacode']}"

    %{
Lat Long: #{lat_long loc['lat_long']}
Location  Country: #{loc['country']}#{region}#{city}
Postal    #{postcode}#{metrocode}#{areacode}
    }
  end

  def lat_long( ll )
    "#{ll[0].abs}#{ll[0] > 0 ? 'N' : 'S'}, #{ll[1].abs}#{ll[1] > 0 ? 'E' : 'W'}"
  end
end

GeoIPManager.new.manage
