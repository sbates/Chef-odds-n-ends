# Defaults, because chef is an automation machine:
# yes - skipx, install, text
# no X - we don't use no stinkin X on servers
# no cmdline, driverdisk, monitor (no X), xconfig (no X), autostep, upgrade; we're chef, we rebuild, not upgrade
# no vnc, graphical, %include - because anything included would be in a recipe after the fact

# This seems exceptionally complex for something that just generates what is essentially a config file.  On the other hand, you could data bag or hash almost everything, making it easy to maintain/build several different configs.

# ks_install, ks_source, ks_network, ks_disk, ks_authconfig, ks_bootloader
# install options
ks_install do
  finish "reboot" # shutdown/reboot/halt/powerdown
  mediacheck false
  log_level "debug"
  log_host "somehost"
  log_port "someport"
  pkg_list ["--nobase", "pkg1", "pkg2", "-pkg3"]
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
  custom_url {"somerepo" => "http://some other repo", "another repo name" =>   "http://something other other repo"]
  custom_mirror {"somemirror" => "http://some.url.com/path/to/stuff"}
end

ks_source "ftp" do
  hostname "ftp.xyz.com"
  path "/some/ftp/path"
  user "user"
  password "password"
end

# network_opts;  assumes --bootproto=dhcp --device=eth0, if nothing provided
# dhcp/static/bootp methods
ks_device "eth0" do
  method "dhcp"
  ipv4 true
  ipv6 false
  end

ks_device "eth0" do
  method "static"
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

# Ideas for kickstart disk partitioning.  Default will still remain clearpart/autopart
# The second set is less easy to read/plan, but is more cheffy.  The first is easy to read and understandable.
# and the resource is flexible

diskargs = ('kickstart', 'diskparams')

diskargs['partition'].each do |part|
  kscfg "partition_#{part['name']}" do
    size part['size']
    raidargs part['raidargs']
    partargs part['partargs']
  end
end

kscfg "partition_swap" do
  partition_size "recommended"
end

diskargs['raid'].each do |rd|
  kscfg rd['name'] do
    size rd['name']
    fstype ['fstype']
    fsoptions rd['fsoptions']
    level rd['level']
    device rd['device']
  end
end

diskargs['volgroup'].each do |volg|
  kscfg volg['name'] do
    partname volg['partname']
    pesize volg['pesize']
  end
end

diskargs['logvol'].each do |lv|
  kscfg lv['name'] do
    vgname lv['vg']
    fstype lv['fstype']
    fsoptions lv['fsoptions']
  end
end
#################################################################################################
#################################################################################################
ks_mount "/" do
  type "raid"
  fstype "ext3"
  raid_device "md0"
  raid_level "RAID1"  #if root and no boot, must be level 1; if boot, boot must be level 1k
  partition {"01" => "sda","02" => "sdb"} #partition number and which drive
  partition_size 1000 #size in mb or --recommended for swap
  grow true
  maxsize  2000 #int
end
# above would generate
# part raid.01 --size 1000 --grow --maxsize 2000 --ondisk=sda
# part raid.02 --size 1000 --grow --maxsize 2000 --ondisk=sdb
# raid / --fstype ext3 --level1 --device=md0 raid.01 raid02
############################################

# one partition, one volgroup, two logvols
# idea is that you just pass in the required parts of the partition/volgroup once
ks_mount "/var" do
  type "logvol"
  fstype "ext3"
  size 32000 #int in megabyptes or --recommended or --percent
  grow false  # default
  volgroup "myvg"   #recipe notices and builds this
  vg_size 64000
  pesize 4096 # physical extents
  partition 01
end
ks_mnt "/usr" do
  type "logvol"
  fstype "ext3"
  size "32000"
  volgroup "myvg"
end
# above would generate
# partition pv.01 --size 64000
# volgroup myvg pv.01 --64000
# logvol /var --fstype=ext3 --vgname=myvg --size=32000 --name=myvg-var
# logvol /usr --fstype=ext3 --vgname=myvg --size=32000 --name=myvg-usr
#####################################################################333333333
ks_mount "/" do
  type "partition"
  fstype "ext3"
  size 32000
  grow false
end
ks_mount "/var" do
  type "partition"
  fstype "ext3"
  size 32000
  grow false
  fsopts {} #anything else they want to use that I'm not handling
end
#above would produce
# partition / --size=32000 --fstype=ext3
# partition /var --size=32000 --fstype=ext3
##########################################33