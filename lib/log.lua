--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-08 13:39:41
--

local skynet = require("skynet")
local dump = require("skynet.datasheet.dump")

log = {}

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

function log.dump( t )
    log.debug(dump.dump(t))
end

return log