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

# Create a temp dir to work in
directory node[:multicraft][:tmp_dir] do
  action :create
end

# Get the latest Multicraft tar. Use HTTP_HEAD to bypass re-download
remote_file "#{node[:multicraft][:tmp_dir]}/multicraft.tar.gz" do
  source node[:multicraft][:download_url]
  mode "0644"
  action :nothing
end

local = "#{node[:multicraft][:home]}/chefrun"
http_request "HEAD #{node[:multicraft][:download_url]}" do
  message ""
  url node[:multicraft][:download_url]
  action :head
  if File.exists?(local)
    headers "If-Modified-Since" => File.mtime(local).httpdate
  end
  notifies :create,"remote_file[#{node[:multicraft][:tmp_dir]}/multicraft.tar.gz]", :immediately
end

file local do
  owner node['apache']['user']
  group node['apache']['group']
  action :create
end

# Extract the Multicraft tar
execute "tar" do
  cwd node[:multicraft][:tmp_dir]
  command "tar -zxf multicraft.tar.gz"
end

# Copy the bin and jar folders to [:home]
execute "cp" do
  user node[:multicraft][:user]
  group node[:multicraft][:group]
  cwd "#{node[:multicraft][:tmp_dir]}/multicraft"
  command "cp -r bin jar #{node[:multicraft][:home]}"
end

# Remove temp files
directory node[:multicraft][:tmp_dir] do
  recursive true
  action :delete
end

# Create the config file
panels = search(:node, "roles:multicraft_panel") || []
Chef::Log.error('No multicraft panels found') if panels.empty?
panels.each do |panel|
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
  
	  :sql_host => panel[:multicraft][:db][:host],
	  :sql_database => panel[:multicraft][:db][:database],
	  :sql_user => panel[:multicraft][:db][:user],
	  :sql_password => panel[:multicraft][:db][:password],
  
	  :ftp_enabled => node[:multicraft][:ftp][:enabled],
	  :ftp_port => node[:multicraft][:ftp][:port],
	  :ftp_forbidden => node[:multicraft][:ftp][:forbidden]
    )
  end
  # Create a multicraft.key if supplied
  file "#{node[:multicraft][:home]}/multicraft.key" do
    action :create
    content panel[:multicraft][:key]
    owner node[:multicraft][:user]
    group node[:multicraft][:group]
    mode "0600"
    not_if {panel[:multicraft][:key].empty?}
  end
end
