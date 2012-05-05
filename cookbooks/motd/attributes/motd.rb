if node.attribute?('ec2')
  default['motd']['image'] = node['ec2']['ami_id']
  default['motd']['flavor'] = node['ec2']['instance_type']
  default['motd']['region'] = node['ec2']['placement_availability_zone']
  default['motd']['node_name'] = node['ec2']['instance_id']
else
  default['motd']['image'] = node['platform']
  default['motd']['flavor'] = node['platform_version']
  default['motd']['region'] = ''
  default['motd']['node_name'] = node['fqdn']
end

if node.attribute?('cloud')
  default['motd']['public_dns'] = node['cloud']['public_hostname']
  default['motd']['public_ip'] = node['cloud']['public_ipv4']
  default['motd']['private_dns'] = node['cloud']['local_hostname']
  default['motd']['private_ip'] = node['cloud']['local_ipv4']
else
  default['motd']['public_dns'] = ''
  default['motd']['public_ip'] = ''
  default['motd']['private_dns'] = node['fqdn']
  default['motd']['private_ip'] = node['ipaddress']
end

default['motd']['roles'] = node.run_list.roles
