## TODO: Header stuff
# Include the OpsCode SSL library for secure password generation
# (Include code used from MySQL Server cookbook)
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "apache2"
include_recipe "mysql::server"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

if node.has_key?("ec2")
  fqdn = node['ec2']['public_hostname']
else
  fqdn = node['fqdn']
end

# Set persistant node variables
node.set_unless[:multicraft][:daemon][:password] = secure_password
node.set_unless[:multicraft][:daemon][:id] = 1
node.set_unless[:multicraft][:db][:password] = secure_password

# Find the multicraft key if supplied
node.set_unless[:multicraft][:key] = ''

# Create a temp dir to work in
directory node[:multicraft][:tmp_dir] do
  action :create
end

# Create the webroot
directory node[:multicraft][:web][:root] do
  action :create
  owner node['apache']['user']
  group node['apache']['group']
  recursive true
end

# Get the latest Multicraft tar. Use HTTP_HEAD to bypass re-download
local = "/tmp/multicraft.tar.gz"
remote_file local do
  source node[:multicraft][:download_url]
  mode "0644"
  action :nothing
end

http_request "HEAD #{node[:multicraft][:download_url]}" do
  message ""
  url node[:multicraft][:download_url]
  action :head
  if File.exists?(local)
	headers "If-Modified-Since" => File.mtime(local).httpdate
  end
  notifies :create,"remote_file[#{local}]", :immediately
end

# Extract the Multicraft tar
execute "tar" do
  cwd node[:multicraft][:tmp_dir]
  command "tar -zxf #{local}"
  only_if { File.exists?(local) }
end

# Copy the panel folder to the webroot
execute "cp" do
  user node['apache']['user']
  group node['apache']['group']
  cwd "#{node[:multicraft][:tmp_dir]}/multicraft"
  command "cp -r panel/* #{node[:multicraft][:web][:root]}"
  only_if { File.exists?("#{node[:multicraft][:tmp_dir]}/multicraft/panel") }
  not_if { File.exists?("#{node[:multicraft][:web][:root]}/panel") } 
end

# Generate the config.php file
template "#{node[:multicraft][:web][:root]}/protected/config/config.php" do
  source "config.php.erb"
  owner node['apache']['user']
  group node['apache']['group']
  mode "0600"
  variables(
    :db => node[:multicraft][:db],
    :daemon_password => node[:multicraft][:daemon][:password]
  )
end

# Overwrite invalid daemon SQL update files to stop errors
[1, 2].each do |i|
  file "#{node[:multicraft][:web][:root]}/protected/data/daemon/update.mysql.#{i}.sql" do
    content ""
    action :create
  end
end

if tagged?("db_bootstrap")
  # Create the MySQL Database/User
  connection_info = {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}
  mysql_database node[:multicraft][:db][:database] do
    connection connection_info
    action :drop
  end

  mysql_database node[:multicraft][:db][:database] do
    connection connection_info
    action :create
  end

  mysql_database_user node[:multicraft][:db][:user] do
    connection connection_info
    password node[:multicraft][:db][:password]
    action :create
  end

  mysql_database_user node[:multicraft][:db][:user] do
    connection connection_info
    password node[:multicraft][:db][:password]
    database_name node[:multicraft][:db][:database]
    action :grant
  end

  # Import the panel/daemon MySQL schema and updates
  ["panel", "daemon"].each do |db|
    i = 1
    sql = "#{node[:multicraft][:web][:root]}/protected/data/#{db}/schema.mysql.sql"
    while File.exists?(sql) do
      execute "mysql-import-multicraft" do
        command "#{node['mysql']['mysql_bin']} -u root -p\"#{node['mysql']['server_root_password']}\" -D #{node[:multicraft][:db][:database]} < #{sql}"
      end
      sql = "#{node[:multicraft][:web][:root]}/protected/data/#{db}/update.mysql.#{i}.sql"
      i += 1
    end
  end
  untag("db_bootstrap")
end

# Create a web_app in Apache using the fqdn
web_app "multicraft" do
  template "web_app.conf.erb"
  server_name fqdn
  server_aliases [node['fqdn']]
  docroot node[:multicraft][:web][:root]
end

# Remove the tmp file
directory node[:multicraft][:tmp_dir] do
  recursive true
  action :delete
end
