# Cookbook Name:: parsehost
# Recipe:: parsehost
#
def parse_host_function(hostname)

    Chef::Log.info("HostParse: parse_host: parsing host #{hostname}")

    parser = HostParser.new
    parser.match_host(hostname)
    parser.set_extra_bits
    parser.assign_hostdata

    Chef::Log.debug("logging the hostdata hash pairs:")
 return parser.hostdata
end

# an example of how you might use this function or use HostParser directly
# if you had, say, a new a set of new servers not yet created that you might want to create seed nodes for
someservers = ["dlplolwmq01", "dxplolweb03", "pvpafpapp01"]
parsedata = ""
someservers.each do |srv| 
  parsedata << "#{srv}:" << parse_host_function(srv).inspect << "\n"
end

file "/tmp/hostdata.txt" do
  content parsedata
end

# Output:
# [root@dvdchfapp05 ~]# cat /tmp/hostdata.txt
# pvplolwmq01:{:application=>"Cheez", :zone=>"internal", :platform=>"linux", :environment=>"prod", :env=>"p", :server_type=>"mq", :location=>"pismo", :loc=>"d"}
# pxplolweb03:{:application=>"Cheez", :zone=>"internal", :platform=>"Solaris", :environment=>"prod", :env=>"p", :server_type=>"web", :location=>"pismo", :loc=>"d"}
# pvppkyapp01:{:application=>Pooky, :zone=>"external", :platform=>"linux", :environment=>"prod", :env=>"p", :server_type=>"application", :location=>"pismo", :loc=>"d"}

