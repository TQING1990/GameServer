local tconcat = table.concat
local tinsert = table.insert
local type = type
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local next = next

local spaceStyle = {
    nextLevelPrefix = function ( prefix )
        return prefix .. "    "
    end,
    tableValue = function ( temp, prefix, key, value )
        if value then
            tinsert(temp, prefix .. key .. " = {")
            tinsert(temp, value)
            tinsert(temp, prefix .. "}")
        else
            tinsert(temp, prefix .. key .. " = {}")
        end
    end,
    noTableValue = function ( prefix, key, value )
        return prefix .. key .. " = " .. value .. ","
    end,
}

function dump( root, des )
    root = { [des or tostring(root)] = root }
    local cache = {  [root] = "." }
    local style = spaceStyle

    local function getValue( k )
        if "string" == type(k) then
            if tonumber(k) then
                return '"' .. k .. '"'
            else
                return k
            end
        else
            return tostring(k)
        end
    end

    local function _dump(t, prefix, name)
        local temp = {}
        for k, v in pairs(t) do
            local key = getValue(k)
            if cache[v] then
                tinsert(temp, prefix .. key .. " = [" .. cache[v].."]")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                local value
                if next(v) then
                    value = _dump(v, style.nextLevelPrefix(prefix, t, k, key), new_key)
                else
                    value = nil
                end
                style.tableValue(temp, prefix, key, value)
            else
                local value = getValue(v)
                tinsert(temp, style.noTableValue(prefix, key, value))
            end
        end
        return tconcat(temp, "\n")
    end

    return _dump(root, "", "")
end

return dump