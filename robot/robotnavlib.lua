--Navigation Functions for Robots

local com = require("component")
local bot = require("robot")
local sides = require("sides")

local nav = com.proxy(com.list("navigation")())

local _x,_y,_z
local _map = {}

local function get_sq_distance(x1,y1,z1,x2,y2,z2)
    (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2)
end

local function update_position()
    _x,_y,_z = nav.getPosition()
    if _x == nil then
        print(y)
    end
end

local function get_position()
    if not _x then
        update_position()
    end
    return _x,_y,_z
end

--[[
local function get_nearest_charger()
    local c={x,y,z}
    local dist,leastdist

    local wps = nav.findWaypoints(400)
    for i=1.wps.n do
        c = wps[i].position
        dist = get_sq_distance(_x,_y,_z,c.x,c.y,c.z)
        if leastdist == nil then
            leastdist = dist
        elseif dist < leastdist then
            leastdist = dist
        end
    end
    return c.x,c.y,c.z
end
]]
local function set_node_impassable(x,y,z)
    if _map[x] == nil then
        _map[x] = {}
        if _map[x][y] == nil then
            _map[x][y] = {}
        end
    end
    _map[x][y][z] = 1
end

local function get_cost(x,y,z)
    if not _map[x] or not _map[x][y] or not _map[x][y][z] then
        return 1
    elseif _map[x][y][z] == 1 then
        return
    end
end

local function get_neighbors(bx, by, bz)
    return {
        { bx - 1, by, bz, sides.negx },
        { bx + 1, by, bz, sides.posx },
        { bx, by, bz - 1, sides.negz },
        { bx, by, bz + 1, sides.posz },
        { bx, by - 1, bz, sides.negy },
        { bx, by + 1, bz, sides.posy }
    }
end

function pathfind(gx, gy, gz)

    -- ["x,y,z"] = x, y, z, gScore, fScore, userData (can be anything, for use with callbacks)
    local sKey = string.format("%d,%d,%d", _x, _y, _z)
    local open = {
        [sKey] = { sx, sY, sZ, 0, get_sq_distance(_x, _y, _z, gx, gy, gz)}
    }
    local closed = {}
    local visited = {
        [sKey] = { _x, _y, _z, nil }
    }

    while true do
        local cKey, current

        -- find the best node in the open set
        do
            local fScore = math.huge
            for key, node in pairs(open) do
                if node[5] < fScore then
                    cKey = key
                    current = node
                    fScore = node[5]
                end
            end
        end

        -- node nodes left, we failed to find the goal
        if not current then
            break
        end

        -- we found the goal
        if current[1] == gx and current[2] == gy and current[3] == gz then
            local path = {}
            local x, y, z
            local key = cKey

            repeat
                x, y, z, data, key = table.unpack(visited[key])
                table.insert(path, 1, { x, y, z })
            until not visited[key]

            return path
        end

        -- remove node from open set, add to closed set
        open[cKey] = nil
        closed[cKey] = current

        -- scan neigbhors
        for _, nPos in ipairs(get_neighbors(current[1], current[2], current[3], current[6])) do
            local x, y, z, data = table.unpack(nPos)
            local nKey = string.format("%d,%d,%d", x, y, z)

            local cost = get_cost(x, y, z, data, current[1], current[2], current[3], current[6])
            if cost then
                local gScore = current[4] + cost

                -- this neighbor has a better gScore then the current node
                -- add it to the open set or update its gScore if it's already there
                if not closed[nKey] and (not open[nKey] or gScore < open[nKey][4]) then
                    visited[nKey] = { x, y, z, data, cKey }
                    open[nKey] = { x, y, z, gScore, gScore + get_sq_distance(x, y, z, gx, gy, gz), data }
                end
            end
        end
    end
end

local function face(gs)
    local s = nav.getFacing()
    while s ~= gs do
        bot.turnRight()
        s = nav.getFacing()
    end
end

local function move(x,y,z)
    local dir
    if x > _x then
        dir = sides.posx
    elseif x < _x then
        dir = sides.negx
    elseif y > _y then
        dir = sides.posy
    elseif y < _y then
        dir = sides.negy
    elseif z > _z then
        dir = sides.posz
    elseif z < _z then
        dir = sides.negz
    end
    face(dir)
    if not _x then
        update_position()
    end
    face(dir)
    if bot.forward() then
        _x,_y,_z = x,y,z
        return true
    else
        set_node_impassable(x,y,z)
        return false
    end
end

local function go_to(gx,gy,gz)
    _map = nil
    _map = {}
    local current_pos

    local current_path = {}
    update_position()
    --while _x ~= gx and _y ~= gy and _z ~= gz do
        if not current_path then
            current_path = pathfind(gx,gy,gz)
        end
        serialization.serialize(current_path)
    --end
end

return {
    go_to = go_to,
    get_position = get_position
}