local t = dofile("tests/support.lua")

local function loadStrings(locale)
    LOC = { GetLocaleCode = function() return locale end }
    STRINGS = { NAMES = {}, RECIPE_DESC = {}, CHARACTERS = { GENERIC = { DESCRIBE = {} } } }
    dofile("main/hh_string.lua")
    return STRINGS
end

t.test("prefab display strings follow the client locale", function()
    local zh = loadStrings("zh")
    local en = loadStrings("en")
    assert(zh.NAMES.HH_SUIT_BUILD == "附魔合成台")
    assert(en.NAMES.HH_SUIT_BUILD == "Enchantment Forge")
    assert(en.RECIPE_DESC.HH_SUIT_BUILD == "Right-click to use.")
    assert(en.CHARACTERS.GENERIC.DESCRIBE.HH_EFFECT_STONE == "Contains a special affix.")
    for key, name in pairs(en.NAMES) do
        if zh.NAMES[key]:find("[\128-\255]") then
            assert(not name:find("[\128-\255]"), key)
        end
    end
    LOC, STRINGS = nil, nil
end)

t.test("all active prefab registrations have English display strings", function()
    local strings = dofile("scripts/enums/hh_prefab_strings_en.lua")
    local count = 0
    for _, path in ipairs({ "scripts/enums/hh_prefabs.lua", "scripts/enums/hh_boss.lua", "scripts/job/hh_job_prefab.lua" }) do
        local file = assert(io.open(path, "rb"))
        for line in file:lines() do
            if not line:match("^%s*%-%-") then
                local id = line:match('^%s*%["(hh_[%w_]+)"%] = {')
                    or line:match('^%s*%["(hh_[%w_]+)"%] = commonEggFn')
                if id then
                    local item = strings[id]
                    assert(item and item.name and item.recipe_str and item.desc, path .. ": " .. id)
                    for _, value in pairs(item) do
                        assert(not value:find("[\128-\255]"), id)
                    end
                    count = count + 1
                end
            end
        end
        file:close()
    end
    assert(count >= 35, count)
end)

return t.count
