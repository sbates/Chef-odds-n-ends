#
# Cookbook Name:: kickstart
# Recipe:: generate_ks
# Author:: Sascha Bates
#

#make sure the directory is there
directory "/var/www/mrepo/ks" do
  action :create
  recursive true
end

base_url = "http://#{node.chef.chef_ip}/mrepo"

# Our versions of Red Hat, platform_version, ruby version and repo URI
version_data = [
    {"rh4" => ["4.8", "1.8.7", "RHServer4.8-x86_64_S11", "1.3.7"]},
    {"rh5" => ["5.5", "1.8.7.334", "RHServer5.5-x86_64/disc1", "1.3.7"]},
    {"rh6" => ["6.0", "1.8.7.299", "RHServer6.0-x86_64/disc1", "1.8.5"]}
]

ks_files = ["server", "vm"] # Kickstart file types

ks_files.each do |file|
  version_data.each do |hash|
    hash.each do |version, values|

      ### Set version-specific variables ###
      rh_ver = values[0] # The Red Hat version aka node.platform_version
      ruby_ver = values[1] # Ruby Version
      rh_uri = values[2] # The URI for the Red Hat repository
      gems_ver = values[3] # Rubygems Version - this is static at the moment, but could change in the future
      bbycustom_uri = "bby-custom-#{rh_ver}" # A common repository URI with the ruby rpms
      # TODO: Fragment -- IP because kickstarts have no DNS
      ruby_packages = [
          "ruby-#{ruby_ver}",
          "ruby-devel-#{ruby_ver}",
          "ruby-libs-#{ruby_ver}",
          "ruby-irb-#{ruby_ver}",
          "ruby-rdoc-#{ruby_ver}"
      ]


      #################### Kickstart File Sections ##################################

      ##### These pkgs unsupported in rh6 and unneeded in rh5
      deprecated_packages = [
          "@text-internet",
          "gtk+",
          "xorg-x11-deprecated-libs"
      ]

      ##### Common Base Packages
      base_packages = [
          "%packages",
          "@base",
          "@core",
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
          "gdbm"
      ]
      ##### We don't want any of these packages.  Some get installed anyway.  This section brought to you by Kickstart Parity
      deleted_packages = [
          "-apmd",
          "-aspell",
          "-aspell-en",
          "-bluez-bluefw",
          "-bluez-hcidump",
          "-bluez-libs",
          "-bluez-utils",
          "-dapl",
          "-dhclient",
          "-dhcpv6_client",
          "-finger",
          "-irda-utils",
          "-jpackage-utils",
          "-jwhois",
          "-lftp",
          "-lha",
          "-libibverbs",
          "-libmthca",
          "-libsdp",
          "-lksctp-tools",
          "-nano",
          "-pcmcia-cs",
          "-pinfo",
          "-rp-pppoe",
          "-rsh",
          "-star",
          "-stunnel",
          "-talk",
          "-vconfig",
          "-wireless-tools",
          "-wpa_supplicant",
          "-hotplug",
          "-cadaver",
          "-fetchmail",
          "-isdn4k-utils",
          "-minicom",
          "-ppp",
          "-wvdial"
      ]

      ##### Common Install Directives
      install_directives = [
          "install",
          "url --url #{base_url}/#{rh_uri}",
          "lang en_US.UTF-8",
          "keyboard us",
          "bootloader --location=mbr",
          "zerombr",
          "text",
          "firstboot --disable",
          "network --device=eth0 --bootproto=dhcp",
          "rootpw --iscrypted $1$",
          "selinux --disabled",
          "authconfig --enableshadow --enablemd5",
          "skipx",
          "timezone --utc America/Chicago"

      ]
      key = "key --skip"
      firewall = "firewall --disabled"
      langsupport = "langsupport --default=en_US.UTF-8 en_US.UTF-8"

      ### Volume Info
      server_vol_info = [
          "clearpart --all --initlabel",
          "part /boot --fstype ext3 --size=100",
          "part pv.17 --size=100 --grow",
          "volgroup VolGroup00 --pesize=32768 pv.17",
          "logvol / --fstype ext3 --name=root --vgname=VolGroup00 --size=10240",
          "logvol swap --fstype swap --name=swap --vgname=VolGroup00 --size=8192",
          "logvol /var --fstype ext3 --name=var --vgname=VolGroup00 --size=5632",
          "logvol /tmp --fstype ext3 --name=tmp --vgname=VolGroup00 --size=2048",
          "logvol /var/logs --fstype ext3 --name=logs --vgname=VolGroup00 --size=30720",
          "logvol /opt/tripwire --fstype ext3 --name=tripwire --vgname=VolGroup00 --size=256",
          "reboot"
      ]

      vm_vol_info = [
          "clearpart --all --initlabel",
          "part / --bytes-per-inode=4096 --fstype=\"ext3\" --grow --size=1",
          "part swap --recommended",
          "reboot"
      ]

      ###### Installing Ruby ###########
      # RH5/6 kickstarts accept definitions of additional repos which can be used to install ruby packages
      # RH4, not so much.  So it gets done in the post section as a command line item
      # This line gets added to install directives and the packages to the package install list.
      # See the post section for RH4.
      bby_custom_repo = "repo --name bby-custom --baseurl #{base_url}/#{bbycustom_uri}"


      ################## End Kickstart #################################

      ################## Post Install Sections #########################
      post = "%post --log=/root/kickstart.post.log"

      rh4_ruby_install = [
          "echo \"installing ruby rpms \"",
          "rpm -ivh #{base_url}/custom/ruby-rhel4/ruby-all-#{ruby_ver}.x86_64.rpm"
      ]


      install_rubygems = [
          "echo \"get and install rubygems\"",
          "echo \"#{node.chef.chef_ip}\t #{node.chef.my_chef_server}\" >> /etc/hosts",
          "cd /tmp",
          "wget #{base_url}/custom/rubygems/rubygems-#{gems_ver}.tar.gz",
          "tar xzf rubygems-#{gems_ver}.tar.gz",
          "cd rubygems-#{gems_ver}",
          "ruby setup.rb",
          "echo '---' > /etc/gemrc",
          "echo ':sources:' >> /etc/gemrc",
          "echo '- http://#{node.chef.my_chef_server}/mrepo/chef/0.9.12/' >> /etc/gemrc",
          "echo 'gem: --no-ri --no-rdoc --bindir /usr/bin' >> /etc/gemrc",
          "echo 'update gems'",
          "gem update",
          "gem update --system",
          "gem install chef"
      ]

      config_chefclient = [
          "mkdir /etc/chef",
          "mkdir /var/log/chef",
          "echo \"grabbing validation certificate\"",
          "wget -P /etc/chef #{base_url}/chef/validation.pem",
          "sed -i '/^$/d' /etc/chef/validation.pem",
          "wget -P /etc/init.d #{base_url}/chef/localgeminstall/chef-0.9.12/distro/redhat/etc/init.d/chef-client",
          "chmod 755 /etc/init.d/chef-client",
          "echo \"setting chef_server_url to http://#{node.chef.mrepo_url}:4000\"",
          "wget -P /etc/chef #{base_url}/chef/client.rb",
          "sed -i 's|^chef_server_url.*$|chef_server_url  \"http://#{node.chef.my_chef_server}:4000\"|g' /etc/chef/client.rb",
          "echo \"chef-client -L /tmp/chef-client.log -N `hostname` -S http://#{node.chef.chef_ip}:4000\" >> /etc/rc.local",
          "echo \"/sbin/chkconfig --add chef-client\" >> /etc/rc.local",
          "echo \"/sbin/chkconfig --level 345 chef-client on\" >> /etc/rc.local",
          "echo \"/sbin/service chef-client restart\" >> /etc/rc.local",
          "echo \"mv /etc/rc.local.orig /etc/rc.local\" >> /etc/rc.local"
      ]

      json_file = [
          "echo \"creating initial node.json file for registration\"",
          "echo { \"run_list\": [ \"role[core]\" ]} >>/etc/chef/node.json "
      ]

      ##### End Post Install Section #####

      ##### Time to make the donuts #####
      template "/var/www/mrepo/ks/rhel#{rh_ver}_x86_64-#{file}.ks" do
        source "rhel_x86_64-template.ks.erb"
        owner "root"
        group "root"
        mode "0755"
        variables(
            :file => file,
            :rh_ver => rh_ver,
            :key => key,
            :install_directives => install_directives.join("\n"),
            :base_packages => base_packages.join("\n"),
            :deleted_packages => deleted_packages.join("\n"),
            :deprecated_packages => deprecated_packages.join("\n"),
            :ruby_packages => ruby_packages.join("\n"),
            :rh4_ruby_install => rh4_ruby_install.join("\n"),
            :post => post,
            :server_vol_info => server_vol_info.join("\n"),
            :vm_vol_info => vm_vol_info.join("\n"),
            :config_chefclient => config_chefclient.join("\n"),
            :install_rubygems => install_rubygems.join("\n"),
            :json_file => json_file.join("\n"),
            :bby_custom_repo => bby_custom_repo,
            :firewall => firewall,
            :langsupport => langsupport
        )
      end
    end
  end
end
