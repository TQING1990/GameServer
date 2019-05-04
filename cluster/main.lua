--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-19 22:01:22
--

local skynet = require("skynet")
local envConfig = require("envConfig")
local cluster = require("skynet.cluster")
local serviceAddress = require("serviceAddress")

local function initEnv( nodeConfig )
    for k, v in pairs(envConfig) do
        skynet.setenv(k, v)
    end

    skynet.setenv("PUBLIC_IP", nodeConfig.publicIP)
end

local function initCluster( node )
    local clusterName = skynet.call(serviceAddress.configd(), "lua", "getClusterName")
    cluster.reload(clusterName)
    cluster.open(node)
end

return function ( handler )
    skynet.start(function ()
        log.info("Let's begin!")
        local node = skynet.getenv("CLUATER_NODE_NAME")
        log.info("cluster node name:", node)
        local s = skynet.uniqueservice("configd")
        local nodeConfig = skynet.call(s, "lua", "getNodeConfig", node)
        initEnv(nodeConfig)
        initCluster(node)
        handler.init(node)
    end)
end