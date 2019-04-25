--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-20 15:32:49
--

local skynet = require("skynet")

local configd

local configCenter = {}

function configCenter.getNodeMap()
    return skynet.call(configd, "lua", "getNodeMap")
end

function configCenter.getAreaConfig( areaID )
    return skynet.call(configd, "lua", "getAreaConfig", areaID)
end

function configCenter.getNodeAreaConfig( node )
    return skynet.call(configd, "lua", "getNodeAreaConfig", node)
end

skynet.init(function ()
    configd = skynet.uniqueservice("configd")
end)

return configCenter