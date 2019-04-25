--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-11 21:14:17
--

local skynet = require "skynet"
local main = require("cluster.main")

local handler = {}

function handler.init( node )
    skynet.newservice("logind")
end

main(handler)