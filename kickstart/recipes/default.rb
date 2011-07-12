#
# Cookbook Name:: kickstart
# Recipe:: default
#

%w{ks custom chef}.each do |dir|
        directory "/var/www/mrepo/#{dir}" do
                action :create
        end
end

include_recipe "kickstart::generate_ks"
