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
  owner 'sonarr'
  group 'sonarr'
end

link "/home/sonarr/.config/NzbDrone" do
  to "/storage/sonarr"
  owner 'sonarr'
  group 'sonarr'
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
  owner 'sonarr'
  group 'sonarr'
  action :create_if_missing
  notifies :run, 'ruby_block[show_details]', :delayed
end
