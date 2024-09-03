if settings.startup["reactor-interface-merged"].value and not mods["bobpower"] then
  data.raw.reactor["nuclear-reactor"].picture.layers[1].filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/reactor.png"
  data.raw.reactor["nuclear-reactor"].picture.layers[1].hr_version.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/hr-reactor.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.layers[1].filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/reactor-heated.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.layers[2].filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/reactor-heated.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.layers[1].hr_version.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/hr-reactor-heated.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.layers[2].hr_version.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/hr-reactor-heated.png"
end

local empty_sprite =
{
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  frame_count = 1,
  width = 1,
  height = 1
}

local function interface_sprite(vector)
  if settings.startup["reactor-interface-merged"].value and not mods["bobpower"] then
    return empty_sprite
  else
    return
    {
      filename = "__Reactor_Interface_Tweaked__/graphics/entity/reactor-interface/reactor-interface.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      frame_count = 1,
      shift = vector,
      render_layer = "wires",
      hr_version = {
        filename = "__Reactor_Interface_Tweaked__/graphics/entity/reactor-interface/hr-reactor-interface.png",
        width = 128,
        height = 128,
        frame_count = 1,
        shift = vector,
        scale = 0.5,
        render_layer = "wires"
      }
    }
  end
end

-- already includes offsets from sprite position
local function interface_led(vector)
  return empty_sprite
  -- {
  --   filename = "__Reactor_Interface_Tweaked__/graphics/entity/reactor-interface/reactor-interface-led.png",
  --   width = 6,
  --   height = 6,
  --   frame_count = 1,
  --   -- shift = vector,
  --   shift = {vector[1] - 0.3125, vector[2] - 0.21875},
  --   hr_version = {
  --     filename = "__Reactor_Interface_Tweaked__/graphics/entity/reactor-interface/hr-reactor-interface-led.png",
  --     width = 12,
  --     height = 12,
  --     frame_count = 1,
  --     -- shift = vector
  --   shift = {vector[1] - 0.3125, vector[2] - 0.21875}
  --   }
  -- }
end

local function interface_led_light(vector)
  return {vector[1] - 0.3125, vector[2] - 0.21875}
end

-- already includes offsets from sprite position
local function interface_connection(vector)
  return
  {
    shadow =
    {
      red = {vector[1] + 1.25, vector[2] + 0.75},
      -- red = {1.25, -0.125},
      green = {vector[1] + 0.75, vector[2] + 0.75}
      -- green = {0.75, -0.125},
    },
    wire =
    {
      red = {vector[1] + 0.25, vector[2]},
      -- red = {0.25, -0.875},
      green = {vector[1] - 0.25, vector[2]}
      -- green = {-0.25, -0.875},
    }
  }
end

local interface_offset =
{
  north = util.by_pixel(0, -28),
  east = util.by_pixel(76, 48),
  south = util.by_pixel(0, 124),
  west = util.by_pixel(-76, 48)
}

data:extend({
  {
    type = "constant-combinator",
    name = "reactor-interface",
    icon = "__base__/graphics/icons/nuclear-reactor.png",
    icon_size = 32,
    flags = {"not-deconstructable", "hide-alt-info", "placeable-off-grid", "placeable-neutral", "player-creation", "hidden"},
    max_health = 120,
    collision_box = {{-2.2, -0.1}, {2.2, 0.1}},
    collision_mask = {"item-layer", "object-layer", "water-tile"},
    selection_box = {{-0.625, -1.6875}, {0.625, -0.4375}},
    selection_priority = 255,
    item_slot_count = 10,
    sprites =
    {
      north = interface_sprite(interface_offset.north),
      east = interface_sprite(interface_offset.east),
      south = interface_sprite(interface_offset.south),
      west = interface_sprite(interface_offset.west)
    },

    activity_led_sprites =
    {
      -- north = interface_led(util.by_pixel(-10,-35)),
      north = interface_led(interface_offset.north),
      east = interface_led(interface_offset.east),
      south = interface_led(interface_offset.south),
      west = interface_led(interface_offset.west)
    },

    -- activity_led_light =
    -- {
    --   intensity = 0.8,
    --   size = 0.5,
    --   color = {r = 1.0, g = 1.0, b = 1.0}
    -- },

    activity_led_light_offsets =
    {
      -- {-0.3125,-0.578125},
      -- util.by_pixel(-10,-35),
      interface_led_light(interface_offset.north),
      interface_led_light(interface_offset.east),
      interface_led_light(interface_offset.south),
      interface_led_light(interface_offset.west)
    },

    circuit_wire_connection_points =
    {
      interface_connection(interface_offset.north),
      interface_connection(interface_offset.east),
      interface_connection(interface_offset.south),
      interface_connection(interface_offset.west)
    },

    circuit_wire_max_distance = 7.5,
    squeak_behaviour = false
  },
  {
    type = "sprite",
    name = "interface-led-sprite",
    filename = "__Reactor_Interface_Tweaked__/graphics/entity/reactor-interface/hr-reactor-interface-led-white.png",
    priority = "extra-high",
    width = 12,
    height = 12,
    shift = {-0.3125, -1.09375}
  }
})
