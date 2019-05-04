--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-08 13:39:41
--

local skynet = require("skynet")
local dump = require("dump")

log = {}
local log = log

function log.debug( ... )
    skynet.error(...)
end

function log.info( ... )
    skynet.error(...)
end

function log.waring( ... )
    skynet.error(...)
end

function log.error( ... )
    skynet.error(...)
end

function log.dump( root, des )
    log.debug(dump(root, des))
end

return log