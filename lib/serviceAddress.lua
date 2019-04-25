--
-- Author: TQ(tqing1128@gmail.com)
-- Date: 2019-04-04 21:20:37
--

require("skynet.manager")

local string_format = string.format

local function createAddressClosure( name )
    return function ( ... )
        return string_format(name, ...)
    end
end

-- 定义别名的时候注意，完整的别名必须限制在16个字符以内
local serviceAddress = {
    loginMaster = createAddressClosure(".login_master"),
    redisd = createAddressClosure(".redisd"),
    configd = createAddressClosure(".configd"),
}

return serviceAddress