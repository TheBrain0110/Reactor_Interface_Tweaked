data:extend({
  {
    type = "item",
    name = "reactor-interface",
    icon = "__base__/graphics/icons/nuclear-reactor.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"hidden"},
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]b",
    place_result = "reactor-interface",
    stack_size = 10
  }
})