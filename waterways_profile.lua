api_version = 4

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")

function handle_canal_classes(profile, way, result)
  local route_type = way:get_value_by_key('Route_type')

  if route_type and route_type ~= '' then
    local route_type_lower = string.lower(route_type)
    local canal_speed = profile.route_speeds.canal or profile.default_speed

    if route_type_lower == 'pcanal' then
      print("MATCH: The route has been classified as 'pcanal'.")
      result.forward_classes['pcanal'] = true
      result.backward_classes['pcanal'] = true
    elseif route_type_lower == 'scanal' then
      print("MATCH: The route has been classified as 'scanal'.")
      result.forward_classes['scanal'] = true
      result.backward_classes['scanal'] = true
    elseif route_type_lower == 'inland' then
      print("MATCH: The route has been classified as 'inland'.")
      result.forward_classes['inland'] = true
      result.backward_classes['inland'] = true
    else
      return -- No canal — leave unchanged
    end

    -- Assign ferry speed and mode to valid canals
    result.forward_speed = canal_speed
    result.backward_speed = canal_speed
    result.forward_mode = mode.ferry
    result.backward_mode = mode.ferry
  end
end

function setup()
  return {
    properties = {
      max_speed_for_map_matching = 180 / 3.6,
      weight_name = 'duration',
      u_turn_penalty = 20,
    },
    default_mode = mode.driving,
    default_speed = 10,
    classes = Sequence { 'pcanal', 'scanal', 'inland' },
    excludable = Sequence {
      Set { 'pcanal' },
      Set { 'scanal' },
      Set { 'inland' }
    },
    route_speeds = { canal = 15 },
  }
end

function process_node(profile, node, result, relations)
end

function process_way(profile, way, result, relations)
  result.forward_mode = profile.default_mode
  result.backward_mode = profile.default_mode

  result.forward_speed = profile.default_speed
  result.backward_speed = profile.default_speed

  handle_canal_classes(profile, way, result)

  WayHandlers.names(profile, way, result, {})
  WayHandlers.weights(profile, way, result, {})
end

function process_turn(profile, turn)
  turn.weight = turn.duration
end

return {
  setup = setup,
  process_way = process_way,
  process_node = process_node,
  process_turn = process_turn
}
