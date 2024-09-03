require "util"

if mods["Realistic_Heat_Glow"] and settings.startup["reactor-interface-merged"].value and not mods["bobpower"] then
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_glow.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/realistic/reactor-heat-glow.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_glow.shift = util.by_pixel(-3, -5)
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/realistic/reactor-heated.png"
  data.raw.reactor["nuclear-reactor"].heat_buffer.heat_picture.hr_version.filename = "__Reactor_Interface_Tweaked__/graphics/entity/nuclear-reactor/realistic/hr-reactor-heated.png"
end
