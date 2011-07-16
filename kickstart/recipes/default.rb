#
# Cookbook Name:: kickstart
# Recipe:: default
#

disk_args = data_bag_item('kickstart', 'disk_params')

kscfg "/var/www/ks/rhel-5.5-x86_64-server.ks" do
  source "url --url #{node['kickstart']['base_url']}/#{rh5_uri}"
  part disk_args['part']
  volgroup disk_args['volgroup']
  logvol disk_args['logvol']
  network "network --device=eth0 --bootproto=dhcp"
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
  moar_opts ["custom_repo" => ["repo --name custom --baseurl #{base_url}/custom-rh5"]]
end

kscfg "/var/www/ks/rhel-5.5-x86_64-vm.ks" do
  source "url --url #{node['kickstart']['base_url']}/custom-rh5"
  part disk_args['part']
  network "network --bootproto=static --ip=10.0.2.15 --netmask=255.255.255.0 --gateway=10.0.2.254 --nameserver=10.0.2.1"
  auth "--enableshadow --enablemd5 --enablecache"
  timezone "--utc America/Chicago"
  selinux "--disabled"
  moar_opts ["repo" => ["--name custom --baseurl #{base_url}/custom-rh5"]]
end