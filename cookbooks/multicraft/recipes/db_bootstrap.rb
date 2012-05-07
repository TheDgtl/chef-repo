## TODO: Header stuff

# THIS RECIPE IS DESTRUCTIVE. It will drop existing tables and reload them.
include_recipe "database"
include_recipe "mysql::server"

panel = search(:node, "role:multicraft_panel").first

# Create the MySQL Database/User
connection_info = {:host => 'localhost', :username => 'root', :password => panel['mysql']['server_root_password']}
mysql_database panel[:multicraft][:db][:database] do
  connection connection_info
  action :drop
end
mysql_database panel[:multicraft][:db][:database] do
  connection connection_info
  action :create
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
["panel", "daemon"].each do |db|
  i = 1
  sql = "#{panel[:multicraft][:web][:root]}/protected/data/#{db}/schema.mysql.sql"
  while File.exists?(sql) do
    execute "mysql-import-multicraft" do
      command "#{panel['mysql']['mysql_bin']} -u root -p\"#{panel['mysql']['server_root_password']}\" -D #{panel[:multicraft][:db][:database]} < #{sql}"
    end
    sql = "#{panel[:multicraft][:web][:root]}/protected/data/#{db}/update.mysql.#{i}.sql"
    i += 1
  end
end

ruby_block "remove_db_bootstrap" do
  block do
    Chef::Log.info("Database bootstrap complete. Remove recipe[multicraft::db_bootstrap]")
    node.run_list.remove("recipe[multicraft::db_bootstrap]") if node.run_list.include?("recipe[multicraft::db_bootstrap]")
  end
  action :create
end

