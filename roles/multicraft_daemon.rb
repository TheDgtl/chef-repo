name "multicraft_daemon"
description "Multicraft daemon"
run_list(
  "recipe[java]",
  "recipe[multicraft::daemon]"
)
