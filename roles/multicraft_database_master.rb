name "multicraft_database_master"
description "database master for the Multicraft daemon"
run_list(
  "recipe[mysql::server]",
  "recipe[database::master]"
)
