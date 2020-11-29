--Navigation Functions for Robots

local com = require("component")
local bot = require("robot")
local sides = require("sides")

local nav = com.proxy(com.list("navigation")())

local _x,_y,_z
local _map = {}

--Basic Navigation Functions

local function get_sq_distance(x1,y1,z1,x2,y2,z2)
    (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2)
end

local function update_position()
    _x,_y,_z = nav.getPosition()
    if _x == nil then
        print(y)
    end
end

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

-- Basic Movement Functions

local function face(gs)
    local s = nav.getFacing()
    while s ~= gs do
        bot.turnRight()
        s = nav.getFacing()
    end
end

local function mx(n)
    update_position()
    local gx = _x + n
    if n > 0 then
        face(sides.posx)
    elseif n < 0 then
        face(sides.negx)
    end
    while _x ~= gx do
        bot.foward()
        update_position()
    end
end

local function my(n)
    update_position()
    local gy = _y + n
    while _y ~= gy do
        if n > 0 then
            bot.up()
        elseif n < 0 then
            bot.down()
        end
        update_position()
    end
end

local function mz(n)
    local gz = _z + n
    if n > 0 then
        face(sides.posz)
    elseif n < 0 then
        face(sides.negz)
    end
    while _z ~= gz do
        bot.foward()
        update_position()
    end   
end

--Pathfinding Functions

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

function pathfind(sX, sY, sZ, gX, gY, gZ)
    sX, sY, sZ = tonumber(sX), tonumber(sY), tonumber(sZ)
    gX, gY, gZ = tonumber(gX), tonumber(gY), tonumber(gZ)
    assert(sX and sY and sZ and gX and gY and gZ, "sX, sY, sZ, eX, eY, and eZ must be numbers")

    -- ["x,y,z"] = x, y, z, gScore, fScore, userData (can be anything, for use with callbacks)
    local sKey = string.format("%d,%d,%d", sX, sY, sZ)
    local open = {
        [sKey] = { sX, sY, sZ, 0, get_sq_distance(sX, sY, sZ, gX, gY, gZ)}
    }
    local closed = {}
    local visited = {
        [sKey] = { sX, sY, sZ, nil }
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
        if current[1] == gX and current[2] == gY and current[3] == gZ then
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
                    open[nKey] = { x, y, z, gScore, gScore + get_sq_distance(x, y, z, gX, gY, gZ), data }
                end
            end
        end
    end
end

--Advanced Movement Functions

local function go_to(gx,gy,gz)
    _map = nil
    _map = {}
    local current_path

    while _x ~= gx and _y ~= gy and _z ~= gz do

    end
end

local function go_to_direct(gx, gy, gz)
    update_position()
    my(gy-_y)
    mz(gz-_z)
    mx(gx-_x)
end

local function go_charge()
    go_to(get_nearest_charger())
end

return {
    go_to = go_to,
    go_charge = go_charge
}