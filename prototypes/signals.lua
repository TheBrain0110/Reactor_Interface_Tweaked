data:extend({
  {
    type = "item-subgroup",
    name = "reactor-signals",
    group = "signals",
    order = "f"
  },
  {
    type = "virtual-signal",
    name = "signal-temperature",
    icons =
    {
      {
        icon = "__base__/graphics/icons/signal/signal_blue.png",
        icon_size = 64, icon_mipmaps = 4
      },
      {
        icon = "__Reactor Interface__/graphics/signal/signal-temperature.png",
        icon_size = 64, icon_mipmaps = 4
      }
    },
    subgroup = "reactor-signals",
    order = "a-a"
  },
  {
    type = "virtual-signal",
    name = "signal-fuel",
    icons =
    {
      {
        icon = "__base__/graphics/icons/signal/signal_blue.png",
        icon_size = 64, icon_mipmaps = 4
      },
      {
        icon = "__Reactor Interface__/graphics/signal/signal-fuel.png",
        icon_size = 64, icon_mipmaps = 4
      }
    },
    subgroup = "reactor-signals",
    order = "a-b"
  },
  {
    type = "virtual-signal",
    name = "signal-reactor-stop",
    icons =
    {
      {
        icon = "__base__/graphics/icons/signal/signal_red.png",
        icon_size = 64, icon_mipmaps = 4
      },
      {
        icon = "__Reactor Interface__/graphics/signal/signal-stop.png",
        icon_size = 64, icon_mipmaps = 4
      }
    },
    subgroup = "reactor-signals",
    order = "a-c"
  }
})