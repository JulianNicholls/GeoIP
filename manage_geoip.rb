#!/usr/bin/env ruby -I.

require 'pp'

require 'locations'
require 'ipranges'
require 'ipholder'
require 'patch_int'

# UI for loading IP blocks and locations, and to allow for checking an IP
class GeoIPManager
  def initialize
    @loc = Locations.new
    @ips = IPRanges.new
  end

  def manage
    loop do
      show_record_counts
      print menu

      case gets.chomp.downcase[0]
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
    print "\nEnter IP as xx.xx.xx.xx or Numeric: "
    response = gets.chomp
    ip = IPHolder.new( response )

    addr = find_one_ip( ip )

    puts addr.nil? ? 'No IP Range found' : ip_data( addr )

    return if addr.nil?

    loc = @loc.find_one( loc_id: addr['loc_id'] )

    puts loc.nil? ? 'No Location Found' : loc_data( loc )
  end

  def find_one_ip( ip )
    puts "\nChecking #{ip}"

    crit = { num_start: { '$lte' => ip.numeric }, num_end: { '$gte' => ip.numeric } }

    @ips.find_one( crit )
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
    ip_s, ip_e   = ip['ip_start'], ip['ip_end']

    <<-END
Range:    #{num_s.with_commas} - #{num_e.with_commas}
IP:       #{ip_s} - #{ip_e} (#{(num_e - num_s + 1).with_commas} Addressses)
Location: #{ip['loc_id']}
    END
  end

  def loc_data( loc )
    region    = fetch_and_title( loc, 'region' )
    city      = fetch_and_title( loc, 'city' )
    postcode  = fetch_and_title( loc, 'postcode' )
    metrocode = fetch_and_title( loc, 'metrocode' )
    areacode  = fetch_and_title( loc, 'areacode' )

    %(
Lat Long: #{lat_long loc['lat_long']}
Location  Country: #{loc['country']}#{region}#{city}
Postal    #{postcode}#{metrocode}#{areacode}
    )
  end

  def fetch_and_title( hash, key )
    value = hash.fetch( key, '' )

    value.empty? ? value : ", #{key.capitalize}: #{value}"
  end

  def lat_long( ll )
    "#{ll[0].abs}#{ll[0] > 0 ? 'N' : 'S'}, #{ll[1].abs}#{ll[1] > 0 ? 'E' : 'W'}"
  end
end

GeoIPManager.new.manage
