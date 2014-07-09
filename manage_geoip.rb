#!/usr/bin/env ruby -I.

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

      case option.to_i
      when 4 then break

      when 1 then load_locations
      when 2 then load_ips
      when 3 then check_ip
      end
    end
  end

  private

  def show_record_counts
    printf "Locations: %9s\n", @loc.count.with_commas
    printf "IP Ranges: %9s\n", @ips.count.with_commas
  end

  def load_locations
    @loc.drop
    @loc.build_from_csv( 'GeoLiteCity-Location.csv' )
  end

  def load_ips
    @ips.drop
    @ips.build_from_csv( 'ips.csv' )
  end

  def menu
    %{
(1) Load Locations.
(2) Load IPs.
(3) Check an IP.

(4) Exit

  Select: }
  end
end

GeoIPManager.new.manage
