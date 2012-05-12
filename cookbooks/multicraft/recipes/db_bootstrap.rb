# TODO: HEADER STUFFS
# This recipe is DESTRUCTIVE. It will drop existing tables and create them from scratch.
# This recipe is expected to be run on an existing panel panel, after the multicraft::panel recipe
include_recipe "database"
include_recipe "mysql::client"

# Check if a panel exists to fill in connection info
panel = search(:node, "role:multicraft_panel").first
if panel.nil?
  connection_info = {:host => 'localhost', :username => 'root', :password => 'password'}
else
  connection_info = {:host => 'localhost', :username => 'root', :password => panel['mysql']['server_root_password']}
end

# Create the MySQL Database/User
mysql_database panel[:multicraft][:db][:database] do
  connection connection_info
  action :drop
end

mysql_database panel[:multicraft][:db][:database] do
  connection connection_info
  action :create
end

mysql_database_user pane[:multicraft][:db][:user] do
  connection connection_info
  action :drop
end

mysql_database_user panel[:multicraft][:db][:user] do
  connection connection_info
  password panel[:multicraft][:db][:password]
  action :create
end

mysql_database_user panel[:multicraft][:db][:user] do
  connection connection_info
  password panel[:multicraft][:db][:password]
  database_name panel[:multicraft][:db][:database]
  action :grant
end

# Import the panel/daemon MySQL schema and updates
ruby_block "import_schema" do
  block do
    ["panel", "daemon"].each do |db|
      i = 1
      sql = "#{panel[:multicraft][:web][:root]}/protected/data/#{db}/schema.mysql.sql"
      while File.exists?(sql) do
        e = Chef::Resource::Execute.new("mysql-import-multicraft", run_context)
        e.command "#{panel['mysql']['mysql_bin']} -u root -p\"#{panel['mysql']['server_root_password']}\" -D #{panel[:multicraft][:db][:database]} < #{sql}"
		e.run_action :run
        sql = "#{panel[:multicraft][:web][:root]}/protected/data/#{db}/update.mysql.#{i}.sql"
        i += 1
      end
    end
  end
  action :create
end

ruby_block "remove_db_bootstrap" do
  block do
    Chef::Log.info("Database bootstrap complete. Removing recipe[multicraft::db_bootstrap]")
    node.run_list.remove("recipe[multicraft::db_bootstrap]")
  end
  action :create
end
