#
# Cookbook Name:: kickstart
# Recipe:: default
#

%w{ks custom chef}.each do |dir|
        directory "/var/www/mrepo/#{dir}" do
                action :create
        end
end

disk_args = data_bag_item('kickstart', 'disk_params')
base_url = "http://#{node.chef.chef_ip}/mrepo"
version_data = [
    {"rh4" => ["4.8", "1.8.7", "RHServer4.8-x86_64_S11", "1.3.7"]},
    {"rh5" => ["5.5", "1.8.7.334", "RHServer5.5-x86_64/disc1", "1.3.7"]},
    {"rh6" => ["6.0", "1.8.7.299", "RHServer6.0-x86_64/disc1", "1.8.5"]}
]

rh_uri

kscfg "/var/www/ks/file1.ks" do

  source "#{node.ks.base_url}/#{rh_uri}"
  network "network --device=eth0 --bootproto=dhcp"
  auth "--enableshadow --enablemd5"
  finish_opts "reboot"
  timezone "--utc America/Chicago"
  selinux "--disabled"
  moar_pkgs [
          "compat-db",
          "lvm2",
          "net-snmp",
          "net-snmp-devel",
          "net-snmp-perl",
          "net-snmp-utils",
          "ntp",
          "openldap",
          "openldap-clients",
          "screen",
          "strace",
          "sysstat",
          "xorg-x11-xauth",
          "zsh",
          "gcc",
          "gdbm",
          "-isdn4k-utils",
          "-minicom",
          "-ppp",
          "-wvdial"
  ]
end
