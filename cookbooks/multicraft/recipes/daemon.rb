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
local = "/tmp/multicraft.tar.gz"
remote_file local do
  source node[:multicraft][:download_url]
  mode "0644"
  action :nothing
  notifies :run, "execute[tar]", :immediately
end

http_request "HEAD #{node[:multicraft][:download_url]}" do
  message ""
  url node[:multicraft][:download_url]
  action :head
  if File.exists?(local)
    headers "If-Modified-Since" => File.mtime(local).httpdate
  end
  notifies :create, "remote_file[#{local}]", :immediately
end

# Extract the Multicraft tar
execute "tar" do
  cwd node[:multicraft][:tmp_dir]
  command "tar -zxf #{local}"
  only_if { File.exists?(local) }
  action :nothing
  notifies :run, "execute[cp]", :immediately
end

# Copy the bin and jar folders to [:home] if they don't exist
execute "cp" do
  user node[:multicraft][:user]
  group node[:multicraft][:group]
  cwd "#{node[:multicraft][:tmp_dir]}/multicraft"
  command "cp -r bin jar #{node[:multicraft][:home]}"
  only_if { File.exists?("#{node[:multicraft][:tmp_dir]}/multicraft/bin") }
  action :nothing
  notifies :run, "execute[multicraft]"
end

# Remove temp files
directory node[:multicraft][:tmp_dir] do
  recursive true
  action :delete
end

# Only run the following if we have a panel
panels = search(:node, "roles:multicraft_panel") || []
Chef::Log.error('No multicraft panels found') if panels.empty?
panels.each do |panel|
  # Create the config file
  template "#{node[:multicraft][:home]}/bin/multicraft.conf" do
    source "multicraft.conf.erb"
    owner node[:multicraft][:user]
    group node[:multicraft][:group]
    mode "0660"
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
	notifies :run, "execute[multicraft]"
  end

  # Create a multicraft.key if supplied
  template "#{node[:multicraft][:home]}/multicraft.key" do
    source "multicraft.key.erb"
    variables(
	  :key => panel[:multicraft][:key]
	)
    owner node[:multicraft][:user]
    group node[:multicraft][:group]
    mode "0660"
    not_if {panel[:multicraft][:key].empty?}
	notifies :run, "execute[multicraft]"
  end
end

# Launch/Restart the daemon if we have a panel
execute "multicraft" do
  user node[:multicraft][:user]
  group node[:multicraft][:group]
  cwd "#{node[:multicraft][:home]}/bin"
  environment ({'PYTHON_EGG_CACHE' => node[:multicraft][:home]})
  command "./multicraft restart"
  not_if { panels.empty? }
  action :nothing
end
