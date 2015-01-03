def default_value(val, default)
  if val.nil?
    return default
  end
  if val === 'true'
    return true
  elsif val === 'false'
    return false
  elsif val.is_a? Numeric
    return BigDecimal.new(val).to_i
  else
    return val
  end
end

def str_to_arr(input)
  input = default_value(input, [])
  if input === []
    return input
  end
  return input.split(',')
end

def generatePassword(length) 
  return rand(36**length).to_s(36)
end

sonarrConfig = {
  :apiKey => default_value(ENV['sonarr_api_key'], generatePassword(30)),
  :userName => default_value(ENV['sonarr_username'], 'sonarr'),
  :password => default_value(ENV['sonarr_password'], generatePassword(10))
}

directory "/storage/sonarr" do
  recursive true
  action :create
  owner 'docker'
  group 'docker'
end

directory "/storage/sonarr/ssl" do
  recursive true
  action :create
  owner 'docker'
  group 'docker'
end

link "/home/docker/.config/NzbDrone" do
  to "/storage/sonarr"
  owner 'docker'
  group 'docker'
end

ruby_block 'show_details' do
  block do
    puts "Your sonarr details are as follows:"
    puts "Username => #{sonarrConfig[:userName]}"
    puts "Password => #{sonarrConfig[:password]}"
    puts "API Key => #{sonarrConfig[:apiKey]}"
  end
  action :nothing
end

template '/storage/sonarr/config.xml' do
  source 'config.xml.erb'
  variables ({ :confvars => sonarrConfig })
  owner 'docker'
  group 'docker'
  action :create_if_missing
  notifies :run, 'ruby_block[show_details]', :delayed
end

execute 'import_ssl' do
  cwd '/storage/sonarr/ssl'
  command <<-EOH
    httpcfg -add -port 9898 -pvk sonarr.local.pvk -cert sonarr.local.cert
    sed -i "s/sonarr-https-hash/$(httpcfg -list | awk '{print $4}')/g" /storage/sonarr/config.xml
  EOH
  action :nothing
end

execute 'create_ssl_certificates' do
  cwd '/storage/sonarr/ssl'
  command <<-EOH
    openssl genrsa -out sonarr.local.key 2048
    openssl req -new -x509 -key sonarr.local.key -out sonarr.local.cert -days 3650 -subj /CN=sonarr.local
    ls -al
    pvk -in sonarr.local.key -topvk -nocrypt -out sonarr.local.pvk
  EOH
  user 'docker'
  group 'docker'
  not_if { File.exist?('/storage/sonarr/ssl/sonarr.local.pvk') }
  notifies :run, 'execute[import_ssl]', :delayed
end


