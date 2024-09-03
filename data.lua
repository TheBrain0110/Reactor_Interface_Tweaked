require("prototypes.entities")
require("prototypes.items")
require("prototypes.signals")

data:extend({
  {
    type = "custom-input",
    name = "reactor-interface-toggle",
    key_sequence = "CONTROL + SHIFT + I"
  }
})

data.raw["reactor"]["nuclear-reactor"].neighbour_collision_increase = 0