name "multicraft_panel"
description "Control panel for Multicraft daemons"
run_list(
  "recipe[apache2]",
  "recipe[apache2::mod_php5]",
  "recipe[database]",
  "recipe[multicraft::panel]"
)
override_attributes(
  :multicraft => {
    :key => "A762-A351-F8C9-0263"
  }
)
