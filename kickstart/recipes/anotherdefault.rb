# Option 3: I define a set of labeled install args that are hashed/databagged and specify requirements and use in the documentation;
# still do logic checks, like, you have to have a volgroup if you define a logvol, etc.
# The hashes below are based on the individual components defined in altdefault.rb

kscfg "ksfile.ks" do
  install_opts {}
  source_opts {}
  network_opts {}
  logging_opts {}
  partition_args {}
  raid_args {}
  volgroup_args {}
  logvol_largs {}
end