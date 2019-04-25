--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-03-31 16:09:15
--

local skynet = require("skynet")
require("skynet.manager")
local serviceAddress = require("serviceAddress")
local redis = require("skynet.db.redis")
local log = require("log")

local redisObj
local function initRedis()
    redisObj = redis.connect {
        host = "127.0.0.1",
        port = 6379,
        auth = "passward",
        db = 9
    }
end

local CMD = {}

function CMD.HGET( h, k )
    return redisObj:HGET(h, k)
end

function CMD.HSET( h, k, v )
    return redisObj:HSET(h, k, v)
end

function CMD.HDEL( h, k )
    return redisObj:HDEL(h, k)
end

local function convertMap( array, index )
    index = index or 1
    local k = array[index]
    local v = array[index + 1]
    array[index] = nil
    array[index + 1] = nil
    if k and v then
        convertMap(array, index + 2)
        array[k] = v
    end
end

function CMD.HGETALL( h )
    local ret = redisObj:HGETALL(h)
    convertMap(ret)
    return ret
end

skynet.start(function ()
    initRedis()

    local function dispatch( session, source, cmd, ... )
        local f = CMD[cmd]
        if f then
            return f(...)
        else
            return redisObj[cmd](redisObj, ...)
        end
    end

    skynet.dispatch("lua", function (session, source, cmd, ...)
        -- skynet.trace()
        if 0 == session then
            dispatch(session, source, cmd, ...)
        else
            skynet.ret(skynet.pack(dispatch(session, source, cmd, ...)))
        end
    end)

    skynet.register(serviceAddress.redisd())
end)