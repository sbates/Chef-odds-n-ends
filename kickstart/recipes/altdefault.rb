# Defaults, because chef is an automation machine:
# yes - skipx, install, text
# no X - we don't use no stinkin X on servers
# no cmdline, driverdisk, monitor (no X), xconfig (no X), autostep, upgrade; we're chef, we rebuild, not upgrade
# no vnc, graphical, %include - because anything included would be in a recipe after the fact

# install options
ks_install_opts do
  finish "reboot" shutdown/reboot/halt/powerdown
  mediacheck false
  log_level "debug"
  log_host "somehost"
  log_port "someport"
end

# source setup; this is chef, will there really be a hdd or cdrom? url/nfs
# nfs/http/ftp
ks_source "nfs" do
  server "someserver"
  directory "some/path/to/dir"
  opts "nfs mount opts"
end

ks_source "http" do
  url "http://xyz.com/ur/uri"
  custom ["http://some other repo", "http://something other other repo"]
end

ks_source "ftp" do
  hostname "ftp.xyz.com"
  path "/some/ftp/path"
  user "user"
  password "password"
end

# network_opts;  assumes --bootproto=dhcp --device=eth0, if nothing provided
# dhcp/static
ks_network "dhcp" do
  ipv4 true
  ipv6 false
  device "eth0"
end

ks_network "static" do
  device "eth0"
  onboot true
  ip "1.2.3.4"
  netmask "255.255.255.0"
  gateway "1.2.3.0"
  nameserver ["192.168.2.1","192.168.3.1"]
end


ks_anaconda_logging  do
  level "debug"
  host "somehost"
  port "someport"
end

