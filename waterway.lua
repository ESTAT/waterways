Set = require('lib/set')
Sequence = require('lib/sequence')
-- Ramón Molinero Parejo <rmolinero@bilbomatica.es>
-- Code adapted from train profile version (https://github.com/railnova/osrm-train-profile)
-- Copyright 2017-2019 Railnova SA <support@railnova.eu>, Nikita Marchant <nikita.marchant@gmail.com>
-- Code under the 2-clause BSD license

-- Define api version (required)
api_version = 4


-- Define avoidable values
local avoidable_route_type = {"PCANAL", "SCANAL"}
local avoidable_route = {"ferry"}

-- Define setup function (required)
function setup()
  return {
    properties = {
      -- Maximum vehicle speed to be assumed in matching (in m/s)
      max_speed_for_map_matching     = 20/3.6, -- 20 kmph -> m/s
      -- Name used in output for the routing Sweight property (default 'duration')
      weight_name                    = 'duration',
      -- Must the route continue straight on at a via point, or are U-turns allowed? (default true)
      continue_straight_at_waypoint  = true,
      -- Avoidable 'Route type' values
      avoidable_route_type           = avoidable_route_type,
      -- Avoidable 'Route' values
      avoidable_route                = avoidable_route,
      
    },
    
    classes = Sequence {
        'PCANAL', 'SCANAL'
    },
    
    excludable = Sequence {
        Set {'PCANAL'},
        Set {'SCANAL'}
    },
    
}

end


function ternary ( cond , T , F )
    if cond then return T else return F end
end

-- Determine whether this node is a barrier or can be passed and whether passing it incurs a delay (optional)
function process_node(profile, node, result, relations)
end

function process_way(profile, way, result, relations)
    local data = {
        -- Get OSM key tag to use
        cemt = way:get_value_by_key('CEMT'),
        maxspeed = way:get_value_by_key('maxspeed'),
        routetype = way:get_value_by_key('Route_type'),
    }
    
    -- Check if the user wants to avoid canal routes

    -- Remove everything that is not a CEMT category between I to VII

    -- default speed
    local default_speed = 20
    -- if OSM specifies a maxspeed, use the one from OSM
    local speed = ternary(data.maxspeed, data.maxspeed, default_speed)

    -- Speed on this way in km/h
    result.forward_speed = speed
    result.backward_speed = speed
    -- Mode of travel on this way (e.g.: driving, cycling, walking, ferry, train, river upstream, river downstream)
    result.forward_mode = mode.ferry
    result.backward_mode = mode.ferry
    -- Routing weight, expressed as meters/weight
    result.forward_rate = 1
    result.backward_rate = 1

end

-- Every possible turn in the network. Based on the angle and type of turn you assign the weight and duration of the movement (optional)
function process_turn(profile, turn)
end

-- Return functions table (required)
return {
    setup = setup,
    process_way = process_way,
    process_node = process_node,
    process_turn = process_turn
}
