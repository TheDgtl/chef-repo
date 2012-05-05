require 'open-uri'

if node['kernel']['machine'] == 'x86_64'
  mc_url = 'http://multicraft.org/files/multicraft-1.6.0-64.tar.gz'
else
  mc_url = 'http://multicraft.org/files/multicraft-1.6.0.tar.gz'
end


set[:multicraft][:home] = '/opt/multicraft'
set[:multicraft][:download_url] = mc_url
set[:multicraft][:tar_name] = 'multicraft.tar.gz'
set[:multicraft][:key] = ''

set[:multicraft][:user] = 'multicraft'
set[:multicraft][:group] = 'multicraft'

set[:multicraft][:daemon][:listen_ip] = '0.0.0.0'
set[:multicraft][:daemon][:listen_port] = '25465'
set[:multicraft][:daemon][:external_ip] = open('http://ifconfig.me/ip').read
#set[:multicraft][:daemon][:password] = 'random' #TODO: Fetch from panel server
set[:multicraft][:daemon][:name] = 'Multicraft Daemon'
#set[:multicraft][:daemon][:id] = '1'
set[:multicraft][:daemon][:log_size] = '20971520'

set[:multicraft][:ftp][:enabled] = 'false'
set[:multicraft][:ftp][:port] = '21'
set[:multicraft][:ftp][:forbidden] = '\.(jar|exe|bat|pif|sh)$'

# Convert memory to MB
mem = node['memory']['total']
set[:multicraft][:max_memory] = (mem[0, mem.length - 2].to_i) / 1024
