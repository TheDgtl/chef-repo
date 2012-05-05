## TODO: Put header here

# Install Java
include_recipe "java"

# Make sure untar is available
package "tar" do
  action :install
end

# Setup the multicraft user group
group node[:multicraft][:group] do
end

# Setup the multicraft user
user node[:multicraft][:user] do
  comment "Multicraft Daemon User"
  home node[:multicraft][:home]
  gid node[:multicraft][:group]
  supports :manage_home => true
end
=begin
# Get the latest Multicraft tar
remote_file "/tmp/multicraft.tar.gz" do
  source node[:multicraft][:download_url]
  mode "0644"
end

# Extract the Multicraft tar
execute "tar" do
  user node[:multicraft][:user]
  group node[:multicraft][:group]
  cwd "/tmp"
  command "tar -zxf #{node[:multicraft][:tar_name]}"
end

# Move the bin and jar folders to [:home]
execute "mv" do
  user node[:multicraft][:user]
  group node[:multicraft][:group]
  cwd "/tmp/multicraft"
  command "mv bin jar #{node[:multicraft][:home]}"
end

# Remove the tmp file
directory "/tmp/multicraft" do
  recursive true
  action :delete
end
=end

# Create the config file
panel = search(:node, "roles:multicraft_panel")
template "#{node[:multicraft][:home]}/bin/multicraft.conf" do
  source "multicraft.conf.erb"
  owner node[:multicraft][:user]
  group node[:multicraft][:group]
  mode "0600"
  variables(
    :user => node[:multicraft][:user],
	:group => node[:multicraft][:group],
	:home => node[:multicraft][:home],
	:max_memory => node[:multicraft][:max_memory],

	:daemon_listen_ip => node[:multicraft][:daemon][:listen_ip],
	:daemon_listen_port => node[:multicraft][:daemon][:listen_port],
	:daemon_external_ip => node[:multicraft][:daemon][:external_ip],
	:daemon_name => node[:multicraft][:daemon][:name],
	:daemon_log_size => node[:multicraft][:daemon][:log_size],

	:daemon_password => panel[:multicraft][:daemon][:password],
	:daemon_id => panel[:multicraft][:daemon][:id],

	:sql_host => panel[:multicraft][:sql][:host],
	:sql_database => panel[:multicraft][:sql][:database],
	:sql_user => panel[:multicraft][:sql][:user],
	:sql_password => panel[:multicraft][:sql][:password],

	:ftp_enabled => node[:multicraft][:ftp][:enabled],
	:ftp_port => node[:multicraft][:ftp][:port],
	:ftp_forbidden => node[:multicraft][:ftp][:forbidden]
  )
end
