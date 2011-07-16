actions :create, :delete

# kickstart file opts
attribute :path,          :kind_of => String, :name_attribute => true
attribute :group,         :regex => Chef::Config[:group_valid_regex]
attribute :mode,          :regex => /^0?\d{3,4}$/
attribute :owner,         :regex => Chef::Config[:group_valid_regex]
attribute :platform,      :default => "redhat" # hopefully can also use ubuntu in the future

# kickstart options; an attribute exists if a)an opt is required or b)I've explicitly set a default
# OR c)if the option is complex and likely to be used (like disk)
# Your options will REPLACE the defaults, NOT append

# disk options; needs checks, need to have part/volgroup/logvol in order and required by each other
attribute :clearpart,     :kind_of => String,:default => "--all --initlabel"
attribute :raid,          :kind_of => Array
attribute :part,          :kind_of => Array, :default => ["autopart", "clearpart --all --initlabel"]
attribute :logvol,        :kind_of => Array
attribute :volgroup,      :kind_of => Array

attribute :zerombr,       :default => true
attribute :install,       :default => true  # set to false for update
attribute :source,        :kind_of => String, :default => "cdrom" # replace with other methods
attribute :key,           :kind_of => String, :default => "--skip" # replace with actual key if desired
attribute :network,       :kind_of => String  # if not set and install is http/ftp/nfs, rh ks assumes dhcp over eth0
attribute :auth,          :kind_of => String, :default => "--enableshadow --enablemd5"
attribute :bootloader,    :kind_of => String, :default => "--location=mbr"
attribute :firewall,      :kind_of => String, :default => "--disabled"
attribute :finish_opts,   :equal_to => ["halt", "poweroff", "shutdown", "reboot"],  :default => "reboot"
attribute :timezone,      :kind_of => String, :default => "--utc"
attribute :selinux,       :kind_of => String, :equal_to => ["--enforcing", "--permissive", "--disabled"], :default => "--permissive"
attribute :skipx,         :default => true  # set to false if xconfig opts desired
attribute :keyboard,      :kind_of => String, :default => "us"
attribute :lang,          :kind_of => String, :default => "en_US"
attribute :rootpw,        :kind_of => String, :default => "icanhazpazzwerd?" # opts: --iscrypted <password>
attribute :text,          :default => true
attribute :moar_opts,     :kind_of => Hash  # for any optional params ex: { "logging" => "--loggingopt1 --loggingopt2"}
attribute :moar_pkgs,     :kind_of => Array # kickstart auto-includes @core, @base; (opts --nobase, pkg1, pkg2, -pkg3)

# RE: post scripts; thinking place them in files directory and the provider will collect them