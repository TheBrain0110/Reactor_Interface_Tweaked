constants = require("reactor-constants")
math2d = require("math2d")
require("util")

function init_global()
  global = global or {}
  global.reactors = global.reactors or {}
  global.reactors_index = global.reactors_index or nil
  global.db_version = constants.db_version
end

function migrate_global(data)
  global.reactors_index = global.reactors_index or nil
  if data.mod_changes[script.mod_name] then
    if global and global.reactors and not global.db_version then
      update_from_version_1()
    end
    if data.mod_changes[script.mod_name].old_version == "2.0.0" then
      -- set interfaces to inoperable to stop GUI from opening in MP
      for _,r in pairs(global.reactors) do
        if r.interface.valid then
          r.interface.operable = false
        end
      end
    end
  end
end

function update_from_version_1()
  local old = global.reactors
  global.reactors = {}
  for _,r in pairs(old) do
    if r.entity and r.entity.valid and r.interface and r.interface.valid then
      local interface = r.interface
      interface.rotatable = true
      interface.direction = defines.direction.north
      interface.rotatable = false
      interface.operable = false
      interface.destructible = false
      interface.teleport(math2d.position.add(r.entity.position, constants.offsets[interface.direction]))
      -- add interface
      register_interface(r.entity, interface)
    end
  end
  global.db_version = constants.db_version
end

-- function upgrade_lights()
--   for _,r in pairs(global.reactors) do
--     r.led = r.led or create_interface_led(r.interface)
--   end
--   global.db_lights = constants.db_lights
-- end

function create_interface_led(interface)
  rendering.draw_light{
    sprite = "interface-led-sprite",
    surface = interface.surface,
    target = interface
  }
  return rendering.draw_sprite{
    sprite = "interface-led-sprite",
    surface = interface.surface,
    target = interface
  }
end

-- create global table entry for interface to be updated
function register_interface(reactor, interface)
  interface.rotatable = false
  interface.operable = false
  interface.destructible = false
  global.reactors[reactor.unit_number] =
  {
    reactor = reactor,
    interface = interface,
    control = interface.get_or_create_control_behavior(),
    signals =
    {
      parameters =
      {
        temp = {signal = table.deepcopy(constants.signal_temp), count = 0, index = 1},
        fuel = {signal = table.deepcopy(constants.signal_fuel), count = 0, index = 2},
        cells = {signal = table.deepcopy(constants.signal_cells), count = 0, index = 3},
        spent = {signal = table.deepcopy(constants.signal_spent), count = 0, index = 4}
      }
    },
    led = create_interface_led(interface)
  }
end

-- remove table entry and destroy interface
function deregister_interface(reactor)
  if reactor and reactor.valid and global.reactors[reactor.unit_number] then
    global.reactors[reactor.unit_number].interface.destroy()
    global.reactors[reactor.unit_number] = nil
    reactor.active = true
  end
end

-- create interface and register it
function create_interface(reactor)
  if not global.reactors[reactor.unit_number] then
    local interface = reactor.surface.create_entity{
      name = constants.interface_name,
      position = math2d.position.add(reactor.position, constants.offsets[defines.direction.north]),
      direction = defines.direction.north,
      force = reactor.force,
      create_build_effect_smoke = false
    }
    register_interface(reactor, interface)
  end
end

-- create and return interface ghost for given reactor
function create_interface_ghost(reactor)
  local interface = reactor.surface.create_entity{
    name = "entity-ghost",
    inner_name = constants.interface_name,
    position = math2d.position.add(reactor.position, constants.offsets[defines.direction.north]),
    direction = defines.direction.north,
    force = reactor.force,
    create_build_effect_smoke = false
  }
  interface.rotatable = false
  return interface
end

-- find interface for given reactor in given direction
function find_interface(reactor, direction)
  local interface_pos = math2d.position.add(reactor.position, constants.offsets[direction])
  local is_ghost = false
  local interface = select(2, next(reactor.surface.find_entities_filtered{
    position = interface_pos,
    limit = 1,
    name = constants.interface_name
  }))
  if not (interface and math2d.position.distance_squared(interface.position, interface_pos) < 1) then
    interface = select(2, next(reactor.surface.find_entities_filtered{
      position = interface_pos,
      limit = 1,
      ghost_name = constants.interface_name
    }))
    if interface and math2d.position.distance_squared(interface.position, interface_pos) < 1 then
      is_ghost = true
    else
      interface = nil
    end
  end
  return interface, is_ghost
end

-- find reactor for given interface
function find_reactor(interface)
  local reactor_pos = math2d.position.subtract(interface.position, constants.offsets[interface.direction])
  local is_ghost = false
  local reactor = select(2, next(interface.surface.find_entities_filtered{
    position = reactor_pos,
    limit = 1,
    type = constants.reactor_type
  }))
  if not (reactor and constants.reactor_names[reactor.name] and math2d.position.distance_squared(reactor.position, reactor_pos) < 1) then
    reactor = select(2, next(interface.surface.find_entities_filtered{
      position = reactor_pos,
      limit = 1,
      ghost_type = constants.reactor_type
    }))
    if reactor and constants.reactor_names[reactor.ghost_name] and math2d.position.distance_squared(reactor.position, reactor_pos) < 1 then
      is_ghost = true
    else
      reactor = nil
    end
  end
  return reactor, is_ghost
end

-- if ghost isn't facing north then find or create north-facing ghost and copy connections
function rotate_interface_ghost(reactor, ghost)
  if ghost.direction ~= defines.direction.north then
    local north_interface,north_is_ghost = find_interface(reactor, defines.direction.north)
    if not north_interface then
      north_interface = create_interface_ghost(reactor)
      north_is_ghost = true
    end
    local connections = ghost.circuit_connection_definitions
    ghost.destroy()
    for _,connection in pairs (connections) do
      north_interface.connect_neighbour(connection)
    end
    if north_is_ghost then
      return north_interface
    else
      return nil
    end
  else
    return ghost
  end
end

-- ensure interface ghost has correct orientation and is on a reactor
function interface_ghost_built(event)
  local ghost = event.created_entity
  local reactor, reactor_is_ghost = find_reactor(event.created_entity)
  if reactor then
    ghost = rotate_interface_ghost(reactor, ghost)
    if ghost then
      if not reactor_is_ghost then
        register_interface(reactor, select(2, ghost.revive()))
      end
    end
  else
    ghost.destroy()
  end
end

-- revive ghost if present, creating new interface if autoplace is enabled
function reactor_built(event)
  local reactor = event.created_entity
  local interface, interface_is_ghost = find_interface(reactor, defines.direction.north)
  if interface then
    if interface_is_ghost then
      interface = select(2, interface.revive())
    end
    register_interface(reactor, interface)
  elseif settings.global["reactor-interface-auto-build"].value then
    create_interface(reactor)
  end
end

-- run the built reactor handler to connect/create an interface as necessary
function reactor_cloned(event)
  reactor_built{created_entity = event.destination}
end

-- make interface die so ghost is created with any connections
function reactor_died(event)
  if global.reactors[event.entity.unit_number] then
    global.reactors[event.entity.unit_number].interface.destructible = true
    global.reactors[event.entity.unit_number].interface.die(nil)
    global.reactors[event.entity.unit_number] = nil
  end
end

-- destroy any interface ghosts in reactor footprint
function reactor_ghost_removed(event)
  local reactor = event.entity or event.ghost
  local interface = find_interface(reactor, defines.direction.north)
  if interface then
    interface.destroy()
  end
end

-- adds/removes interfaces on reactors and reactor ghosts
function hotkey_pressed(event)
  local selection = game.players[event.player_index].selected
  if selection then
    if selection.name == "entity-ghost" then
      if constants.reactor_names[selection.ghost_name] then
        local interface = find_interface(selection, defines.direction.north)
        if interface then
          interface.destroy()
        else
          create_interface_ghost(selection)
        end
      elseif selection.ghost_name == constants.interface_name then
        selection.destroy()
      end
    elseif constants.reactor_names[selection.name] then
      if global.reactors[selection.unit_number] then
        deregister_interface(selection)
      else
        create_interface(selection)
      end
    elseif selection.name == constants.interface_name then
      selection.destroy()
    end
  end
end

function entity_built(event)
  if event.created_entity.name == "entity-ghost" and event.created_entity.ghost_name == constants.interface_name then
    interface_ghost_built(event)
  elseif constants.reactor_names[event.created_entity.name] then
    reactor_built(event)
  end
end


-- Not a loop. Only runs once per tick, and stores index in global.
function tick_interfaces()
  local k,v = next(global.reactors, global.reactors_index)
  global.reactors_index = k
  if v then
    local reactor, interface = v.reactor, v.interface
    if reactor.valid and interface.valid then
      local led = v.led
      if not led or not rendering.is_valid(led) then
        led = create_interface_led(interface)
        v.led = led
      end
      if reactor.to_be_deconstructed() then
        v.control.parameters = nil
      else
        local parameters = v.signals.parameters
        parameters.temp.count = reactor.temperature
        local burner = reactor.burner
        if burner then  -- Add burner fuel signals if burner is present
          local cell_type, cell_count = next(burner.inventory.get_contents(), nil)
          local spent_type, spent_count = next(burner.burnt_result_inventory.get_contents(), nil)
          parameters.fuel.count = math.ceil(100 * burner.remaining_burning_fuel / (burner.currently_burning and burner.currently_burning.fuel_value or 1))
          if cell_type then
            parameters.cells.signal.name = cell_type
            parameters.cells.count = cell_count
          else
            parameters.cells.count = 0
          end
          if spent_type then
            parameters.spent.signal.name = spent_type
            parameters.spent.count = spent_count
          else
            parameters.spent.count = 0
          end
        end
        v.control.parameters = parameters
        if interface.get_merged_signal(constants.signal_stop) > 0 then
          reactor.active = false
          rendering.set_color(led, constants.colours.paused)
        else
          reactor.active = true
          if reactor.temperature < 500 then
            rendering.set_color(led, constants.colours.cold)
          elseif reactor.temperature > 999.5 then
            rendering.set_color(led, constants.colours.hot)
          else
            rendering.set_color(led, constants.colours.ready)
          end
        end
      end
    else
      if interface.valid then
        interface.destroy()
      end
      if reactor.valid then
        reactor.active = true
      end
      global.reactors[k] = nil
    end
  end
end

-- events to capture

-- init
script.on_init(init_global)

-- config changed
script.on_configuration_changed(migrate_global)

-- player built reactor or interface ghost
script.on_event(defines.events.on_built_entity, entity_built,
{{filter="type", type = constants.reactor_type},
{filter="ghost_name", name = constants.interface_name}})
-- robot built reactor
script.on_event(defines.events.on_robot_built_entity, entity_built,
{{filter="type", type = constants.reactor_type}})

-- reactor died
script.on_event(defines.events.on_entity_died, reactor_died,
{{filter="type", type = constants.reactor_type}})

-- reactor ghost was deconstructed
script.on_event(defines.events.on_pre_ghost_deconstructed, reactor_ghost_removed,
{{filter="ghost_type", type = constants.reactor_type}})
-- reactor ghost was removed by player
script.on_event(defines.events.on_pre_player_mined_item, reactor_ghost_removed,
{{filter="ghost_type", type = constants.reactor_type}})

-- reactor was cloned
script.on_event(defines.events.on_entity_cloned, reactor_cloned,
{{filter="type", type = constants.reactor_type}})

-- hotkey pressed
script.on_event("reactor-interface-toggle", hotkey_pressed)

-- update interfaces
-- remove interface if the reactor is no longer valid
script.on_event(defines.events.on_tick, tick_interfaces)
