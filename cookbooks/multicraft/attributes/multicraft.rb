require 'open-uri'

if node['kernel']['machine'] == 'x86_64'
  mc_url = 'http://multicraft.org/files/multicraft-1.6.0-64.tar.gz'
else
  mc_url = 'http://multicraft.org/files/multicraft-1.6.0.tar.gz'
end


default[:multicraft][:home] = '/opt/multicraft'
default[:multicraft][:download_url] = mc_url
default[:multicraft][:tar_name] = 'multicraft.tar.gz'
default[:multicraft][:key] = ''

default[:multicraft][:user] = 'multicraft'
default[:multicraft][:group] = 'multicraft'

default[:multicraft][:daemon][:listen_ip] = '0.0.0.0'
default[:multicraft][:daemon][:listen_port] = '25465'
default[:multicraft][:daemon][:external_ip] = open('http://ifconfig.me/ip').read
#default[:multicraft][:daemon][:password] = 'random' #TODO: Fetch from panel server
default[:multicraft][:daemon][:name] = 'Multicraft Daemon'
#default[:multicraft][:daemon][:id] = '1'
default[:multicraft][:daemon][:log_size] = '20971520'

default[:multicraft][:ftp][:enabled] = 'false'
default[:multicraft][:ftp][:port] = '21'
default[:multicraft][:ftp][:forbidden] = '\.(jar|exe|bat|pif|sh)$'

# Convert memory to MB
mem = node['memory']['total']
default[:multicraft][:max_memory] = (mem[0, mem.length - 2].to_i) / 1024
