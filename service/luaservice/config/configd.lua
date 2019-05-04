--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-19 22:15:27
--

local skynet = require("skynet")
local redis = require("skynet.db.redis")
local cjson = require("cjson")
local serviceAddress = require("serviceAddress")

local clusterConfig
local clusterName = {}
local function initClusterConfig( redisObj )
    local function convertMap(array, index)
        index = index or 1
        local k = array[index]
        local v = array[index + 1]
        array[index] = nil
        array[index + 1] = nil
        if k and v then
            convertMap(array, index + 2)
            array[k] = cjson.decode(v)
        end
    end

    clusterConfig = redisObj:HGETALL("clusterConfig")
    convertMap(clusterConfig)

    for k, v in pairs(clusterConfig) do
        clusterName[k] = v.privateIP .. ":" .. v.port
    end
end

local areaConfig
local nodeAreaConfig = {}
local function initAreaConfig( redisObj )
    local function convertMap(array, index)
        index = index or 1
        local k = array[index]
        local v = array[index + 1]
        array[index] = nil
        array[index + 1] = nil
        if k and v then
            convertMap(array, index + 2)
            array[tonumber(k)] = cjson.decode(v)
        end
    end

    areaConfig = redisObj:HGETALL("areaConfig")
    convertMap(areaConfig)

    for areaID, v in pairs(areaConfig) do
        nodeAreaConfig[v.node] = nodeAreaConfig[v.node] or {}
        nodeAreaConfig[v.node][areaID] = v
    end
end

local CMD = {}

function CMD.getClusterName()
    skynet.retpack(clusterName)
end

function CMD.getNodeMap()
    -- statements
    local map = {}
    for node, _ in pairs(clusterConfig) do
        map[node] = node
    end

    return map
end

function CMD.getNodeConfig( node )
    skynet.retpack(clusterConfig[node])
end

function CMD.getAreaConfig( areaID )
    skynet.retpack(areaConfig[areaID])
end

function CMD.getNodeAreaConfig( node )
    skynet.retpack(nodeAreaConfig[node])
end

skynet.start(function ()
    local redisObj =
        redis.connect {
        host = "127.0.0.1",
        port = 6379,
        auth = "1",
        db = 9
    }

    initClusterConfig(redisObj)
    initAreaConfig(redisObj)

    redisObj:disconnect()

    skynet.dispatch("lua", function( session, source, cmd, ... )
        CMD[cmd](...)
    end)

    skynet.register(serviceAddress.configd())
end)