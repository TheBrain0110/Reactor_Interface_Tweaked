data:extend({
  {
    type = "bool-setting",
    name = "reactor-interface-merged",
    setting_type = "startup",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "reactor-interface-auto-build",
    setting_type = "runtime-global",
    default_value = true,
    order = "b"
  },
	{
		type = "int-setting",
		name = "reactor-interface-tick-interval",
		setting_type = "runtime-global",
		default_value = 10,
    minimum_value = 1,
    order = "c",
    hidden = true
	}
})