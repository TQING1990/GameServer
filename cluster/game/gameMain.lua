--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-14 22:06:11
--
local skynet = require "skynet"
local main = require("cluster.main")
local configCenter = require("configCenter")
-- local serviceAddress = require("serviceAddress")

local handler = {}

function handler.init( node )
    -- local nodeAreaConfig = skynet.call(serviceAddress.configd(), "getNodeAreaConfig", node)
    local nodeAreaConfig = configCenter.getNodeAreaConfig(node)
    local publicID = skynet.getenv("PUBLIC_IP")
    for areaID, v in pairs(nodeAreaConfig) do
        local address = publicID
        local port = v.gatePort
        local gate = skynet.newservice("gated", node, areaID, address, port)
        local gateConfig = {
            address = address, -- 监听地址 127.0.0.1
            port = port,    -- 监听端口 8888
            maxclient = 1024,   -- 最多允许 1024 个外部连接同时建立
            nodelay = true,     -- 给外部连接设置  TCP_NODELAY 属性
            servername = tostring(areaID),
        }
        skynet.call(gate, "lua", "open", gateConfig)
    end
end

main(handler)