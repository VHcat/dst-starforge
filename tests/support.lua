-- Minimal DST services for running the original components under Lua 5.1.
for name in pairs(package.loaded) do
    if name:match("^components/") or name:match("^utils/")
        or name:match("^enums/") or name:match("^widgets/") then
        package.loaded[name] = nil
    end
end
package.path = "./scripts/?.lua;" .. package.path

function Class(ctor)
    local cls = { _ctor = ctor }
    cls.__index = cls
    return setmetatable(cls, { __call = function(c, ...)
        local instance = setmetatable({}, c)
        ctor(instance, ...)
        return instance
    end })
end
local function preload(name, value)
    package.preload[name] = function() return value end
end
for _, name in ipairs({ "widget", "image", "text", "imagebutton", "truescrollarea", "uianim" }) do
    preload("widgets/" .. name, {})
end
preload("enums/hh_text_config", {})
preload("enums/hh_language", {})
preload("enums/hh_effects", { player = {}, monster = {} })
preload("enums/hh_items", { z_clean_stone = { name = "clean stone" } })
preload("enums/hh_prefab_list", { boss_monster = {}, elite_monster = {} })
preload("enums/hh_enchant", {
    HH_EQUIP_BUFF_LIST = { alpha = {}, beta = {} },
    HH_GEM_BUFF_LIST = { gem_a = {}, gem_b = {} },
    HH_SUIT_LIST = {}, HH_SUIT_RECIPE = {},
})
preload("enums/hh_skin", { test_item = { { skin_id = "a" }, { skin_id = "b" } } })
function table.contains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end
json = { encode = function() return "{}" end }
local utils = require("utils/hh_utils")
utils.HHClientRpc = function() end
utils.NetSay = function() end

local support = { utils = utils, count = 0 }
function support.entity()
    return {
        components = {},
        IsValid = function() return true end,
        HasTag = function() return false end,
        DoTaskInTime = function() return { Cancel = function() end } end,
    }
end
function support.test(name, fn)
    local ok, err = pcall(fn)
    if not ok then error(name .. ": " .. tostring(err), 0) end
    support.count = support.count + 1
    print("  PASS " .. name)
end
return support
