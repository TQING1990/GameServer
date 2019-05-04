--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-28 21:15:33
--

local hashTable = require("hashTable")

local skynet = require("skynet")

local HANDLE_INDEX = 0
local function newHandle()
	HANDLE_INDEX = HANDLE_INDEX + 1
	return HANDLE_INDEX
end

local WARING_KEY_COUNT = 10000
local WARING_HANDLE_COUNT = 10000
local WARING_TRIGGER_COUNT = 100

local triggerSystem = {}

local function getDefaultTrigger()
	return { callbacks = {}, handles = {}, keyCount = 0, handleCount = 0 }
end

function triggerSystem.init( obj )
	assert("table" == type(obj))
	obj.trigger = obj.trigger or getDefaultTrigger()
end

function triggerSystem.destroy( obj )
	obj.trigger = nil
end

function triggerSystem.clean( obj )
	obj.trigger = getDefaultTrigger()
end

local function isCallbackExist( trigger, key, callback )
    local callbackMap = trigger.callbacks[key]
    if callbackMap then
        if callbackMap[callback] then
            return true
        else
            return false
        end
    else
        return false
    end
end

local function setCallback( trigger, key, callback, handle )
	local callbackMap = trigger.callbacks[key]
	if not callbackMap then
		callbackMap = {}
        trigger.callbacks[key] = callbackMap
        trigger.keyCount = trigger.keyCount + 1
        if trigger.keyCount >= WARING_KEY_COUNT then
            log.waring("triggerSystem key count =", trigger.keyCount)
        end
	end
    callbackMap[callback] = handle
    callbackMap[handle] = callback
end

local function removeCallback( trigger, key, handle )
    local callbackMap = trigger.callbacks[key]
    local callback = callbackMap[handle]
    callbackMap[callback] = nil
    callbackMap[handle] = nil
    if not next(callbackMap) then
        trigger.callbacks[key] = nil
        trigger.keyCount = trigger.keyCount - 1
    end
end

local function getHandleKey( trigger, handle )
    if trigger.handles[handle] then
        return true
    else
        return false
    end
end

local function setHandleKey( trigger, handle, key )
	trigger.handles[handle] = key
    trigger.handleCount = trigger.handleCount + 1
    if trigger.handleCount >= WARING_HANDLE_COUNT then
        log.waring("triggerSystem handle count =", trigger.handleCount)
    end
end

local function removeHandleKey( trigger, handle )
    trigger.handles[handle] = nil
    trigger.handleCount = trigger.handleCount - 1
end

function triggerSystem.subscribe( obj, key, callback )
    local trigger = obj.trigger

    assert(not isCallbackExist(trigger, key, callback))

    local handle = newHandle()
    setCallback(trigger, key, callback, handle)
    setHandleKey(trigger, handle, key)

	return handle
end

function triggerSystem.unsubscribe( obj, handle )
    local trigger = obj.trigger

	local key = getHandleKey(trigger, handle)
    if key then
        removeHandleKey(trigger, handle)
        removeCallback(trigger, key, handle)
		return true
	else
		return false
	end
end

function triggerSystem.trigger( obj, key, ... )
	local callbackMap = obj.trigger.callbacks[key]
    if callbackMap then
        local count = 0
		for key, callback in pairs(callbackMap) do
            skynet.fork(callback, ...)
            count = count + 1
        end
        if count >= WARING_TRIGGER_COUNT then
            log.waring("triggerSystem trigger count =", count)
        end
    end
end