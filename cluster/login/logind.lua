local login = require "snax.loginserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local cluster = require("skynet.cluster")
local cjson = require("cjson")

local server = {
	host = "0.0.0.0",
	port = 8001,
	instance = 8,
	multilogin = false,	-- disallow multilogin
	name = "login_master",
}

local server_list = {}
local user_online = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	assert(password == "password", "Invalid password")
	-- 可以在这里验证 SDK

	local uid = user
	local areaID = 1
	server = tostring(areaID)

	return server, uid
end

function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))

	-- server 是server.auth_handler的第一个返回值
	-- uid 是server.auth_handler的第二个返回值
	-- uid 通常是第三方平台的唯一ID，需要的话转换为游戏用的ID
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		cluster.call(last.node, last.address, "kick", uid, last.subid)
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	local subid, gateIP, gatePort = cluster.call(gameserver.node, gameserver.address, "login", uid, secret)
	subid = tostring(subid)
	user_online[uid] = { node = gameserver.node, address = gameserver, subid = subid , server = server}

	-- 本函数的返回值是发给客户端的
	-- 如果游戏服是服务器根据负载均衡来分配的，
	-- 那么这里返回分配的游戏服网关信息
	local serverInfo = cjson.encode({
		gateName = server,
		gateAddress = gateIP,
		gatePort = gatePort,
		uid = uid,
		subid = subid,
	})

	return serverInfo
end

local CMD = {}

function CMD.register_gate(server, node, address)
	skynet.error("register_gate", server, node, address)
	server_list[server] = {
		node = node,
		address = address,
	}
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s@%s is logout", uid, u.server, subid))
		user_online[uid] = nil
	end
end

function server.command_handler(command, ...)
	skynet.error("command_handle", command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
