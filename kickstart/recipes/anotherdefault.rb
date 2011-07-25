{"install"=>"default", "packages"=>"oracle", "logging"=>"default", "rootpw","default", "source"=>"rh4", "network"=>"default", "disk"=>"server_default"}.each do |k,v|
   oracle_server_ksvars << ks_#{k} = search("kickstart", "#{k}:#{v}")
end

oracfgs = Kscfg.new
oracfgs.somestuffIhaventwrittenyet(oracle_server_ksvars) #some functionality to massage the data


template "/var/www/mrepo/ks/oracle_server.ks" do
  owner "root"
  group "root"
  mode 0644
  variables (:orafileargs  => :orafileargs)
end
