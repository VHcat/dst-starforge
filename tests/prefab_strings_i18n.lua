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

return t.count
