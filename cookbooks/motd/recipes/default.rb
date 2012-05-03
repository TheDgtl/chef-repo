#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# EC2 specific variables
image = ''
flavor = ''
region = ''
nodename = ''
if node.attribute?('ec2') 
  image = node['ec2']['ami_id']
  flavor = node['ec2']['instance_type']
  region = node['ec2']['placement_availability_zone']
  nodename = node['ec2']['instance_id']
end

roles = node.run_list.roles

template "/etc/motd.tail" do
  source "motd.tail.erb"
  group "root"
  owner "root"
  mode "0644"
  action :create
  variables(
	# EC2 specific variables
	:nodename => nodename,
	:image => image,
	:flavor => flavor,
	:region => region,
    # More general variables
	:kernel => node['os_version'],
	:publicdns => node['cloud']['public_hostname'],
	:publicip => node['cloud']['public_ipv4'],
	:privatedns => node['cloud']['local_hostname'],
	:privateip => node['cloud']['local_ipv4'],
	:roles => roles
  )
end
