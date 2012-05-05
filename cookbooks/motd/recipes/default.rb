#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/motd.tail" do
  source "motd.tail.erb"
  group "root"
  owner "root"
  mode "0644"
  action :create
  variables(
	# EC2 specific variables
	:node_name => node['motd']['node_name'],
	:image => node['motd']['image'],
	:flavor => node['motd']['flavor'],
	:region => node['motd']['region'],
    # Cloud specific variables
	:public_dns => node['motd']['public_dns'],
	:public_ip => node['motd']['public_ip'],
	:private_dns => node['motd']['private_dns'],
	:private_ip => node['motd']['private_ip'],
	# General variables
	:kernel => node['os_version'],
	:roles => node['motd']['roles']
  )
end
