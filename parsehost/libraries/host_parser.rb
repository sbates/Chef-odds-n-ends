require 'chef/data_bag_item'
require 'chef/node'

class Chef::Recipe::HostParser
  require 'chef/data_bag_item'
  attr_reader :hostdata

  def initialize
    @hostdata = Hash.new
    @hostbits = Chef::DataBagItem.load("ohai", "hostbits")
  end

  def match_host(hostname)
    @hostmatch = /(\w)(\w)(\w)(\w\w\w)(\w\w\w)(\d*)/.match(hostname).to_a
    @hostmatch.shift
    @loc, @plat, @env, @app, @server_type, @seq = @hostmatch
  end
  
  def set_extra_bits
    @hostdata[:loc] = @loc
    @hostdata[:env] = @env
    @hostbits["zones"].value?(@app) ? (@hostdata[:zone] = @hostbits["zones"].index(@app)) : (@hostdata[:zone] = "unzoned")
  end

  def assign_hostdata
    @hostbits.keys.each do |k|
      if @hostbits[k]["index"]
        matched = @hostmatch[@hostbits[k]["index"]]
        hostdata[k.chop.to_sym] = @hostbits[k][matched]
      end
    end
  end
end
