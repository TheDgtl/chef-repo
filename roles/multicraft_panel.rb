name "multicraft_panel"
description "Control panel for Multicraft daemons"
run_list (
  "recipe[mysql::client]",
  "recipe[application]"
)

