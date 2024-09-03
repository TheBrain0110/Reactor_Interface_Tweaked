return
{
  db_version = 2,
  reactor_name = "nuclear-reactor",
  reactor_names =
  {
    ["nuclear-reactor"] = true,
    ["nuclear-reactor-2"] = true,
    ["nuclear-reactor-3"] = true
  },
  reactor_type = "reactor",
  interface_name = "reactor-interface",
  signal_temp = {type = "virtual", name = "signal-temperature"},
  signal_fuel = {type = "virtual", name = "signal-fuel"},
  signal_stop = {type = "virtual", name = "signal-reactor-stop"},
  signal_cells = {type = "item", name = "uranium-fuel-cell"},
  signal_spent = {type = "item", name = "used-up-uranium-fuel-cell"},
  reactor_size = 5,
  offsets =
  {
    [defines.direction.north] = {x = 0, y = 2.375},
    [defines.direction.east] = {x = -2.375, y = 0},
    [defines.direction.south] = {x = 0, y = -2.375},
    [defines.direction.west] = {x = 2.375, y = 0},
  },
  colours = {
    paused = {1.0, 0.15, 0.15},
    ready = {0.2, 1.0, 0.2},
    hot = {1.0, 1.0, 0},
    cold = {0, 0.9, 1.0}
  }
}