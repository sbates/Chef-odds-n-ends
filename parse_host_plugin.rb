provides  "environment", "location", "hostdata"
require_plugin "#{linux}{os}::hostname"
hostdata Mash.new
Ohai::Log.debug("ohai plugin: parse_host: parsing new host #{hostname}")

hostbits = {
    :locations =>    { "d"=>"denver", "p"=>"pismo", "h"=>"hanover"},
    :platforms =>    { :index => 1, "x"=>"linux", "l"=>"linux", "w"=>"windows", "v"=>"linux_vm"},
    :environments => { "d"=>"dev", "q"=>"qa", "s"=>"stage", "p"=>"prod", "r"=>"prod"},
    :applications => { :index => 3, "chf"=>"Chef", "ols"=>"OLS", "oms"=>"OMS", "pky"=>"Pooky", "src"=>"Search"},
    :server_types => { :index => 4, "db"=>"database", "app"=>"application", "bch"=>"batch", "img"=>"image", "wmq"=>"mq", "web"=>"web"}
}

def match_host(hostname)
  @hostmatch = /(\w)(\w)(\w)(\w\w\w)(\w\w\w)(\d*)/.match(hostname).to_a
  @hostmatch.shift
  @loc, plat, @env, app, server_type, seq = @hostmatch
end

def set_host_location
  if hostbits[:locations].key?(@loc)
    location hostbits[:locations][@loc]
  else
    location  "default"
  end
  hostdata[:loc] = @loc
end

def set_host_environment
  if hostbits[:environments].key?(@env)
    location == "hanover" ? (environment  "ps") : (environment  hostbits[:environments][@env])
  else
    environment  "dev"
    Ohai::Log.warn("could not set node environment due to unknown identifier #{@env}.Setting to default of d(for dev)")
  end
  hostdata[:env] = @env
end

def assign_hostdata
  hostbits.keys.each do |k|
    if hostbits[k][:index]
      matched = @hostmatch[hostbits[k][:index]]
      hostdata[k.to_s.chop] = hostbits[k][matched]
    end
  end
end


match_host(hostname)
set_host_location
set_host_environment
assign_hostdata