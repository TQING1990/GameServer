--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-22 23:20:25
--

local skynet = require("skynet")
local configCenter = require("configCenter")

local nodeMap
local function initNodeMap()
    nodeMap = configCenter.getNodeMap()
    for k, _ in pairs(nodeMap) do
        nodeMap[k] = false
    end
end

local function isAllOpen()
    for _, v in pairs(nodeMap) do
        if not v then
            return false
        end
    end

    return true
end

local CMD = {}

local waitAllOpenCo = {}

local function newNode( node )
    -- statements
end

local initCluster = true
function CMD.open( node )
    if initCluster then
        if nil == nodeMap[node] then
            error("no config node:" .. node)
        elseif false == nodeMap[node] then
            nodeMap[node] = true
            if isAllOpen() then
                for _, co in ipairs(waitAllOpenCo) do
                    skynet.wakeup(co)
                end
                skynet.ret()
                initCluster = nil
            else
                table.insert(waitAllOpenCo, coroutine.running())
                skynet.wait()
                skynet.ret()
            end
        else
            error("repeat open" .. node)
        end
    else
        if nil == nodeMap[node] then
            newNode(node)
        else
            error("repeat open node:" .. node)
        end
    end
end

skynet.start(function ()
    initNodeMap()
    skynet.dispatch("lua", function ( session, source, cmd, ... )
        local f = assert(CMD[cmd])
        f(...)
    end)
end)