name "multicraft"
description "Multicraft daemon"
run_list (
  "recipe[java]",
  "recipe[multicraft::daemon]"
)
