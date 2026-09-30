local t = dofile("tests/support.lua")
local loadItems = assert(loadfile("scripts/enums/hh_items.lua"))
local function itemConfig(language)
    LOC = {GetLocaleCode=function() return language end}
    return loadItems()
end
t.test("all item IDs and gameplay flags are stable across locales", function()
    local zh, en = itemConfig("zh"), itemConfig("en")
    local count = 0
    for id, item in pairs(zh) do
        count = count + 1
        assert(en[id] and en[id].is_item == item.is_item)
        assert(en[id].person_only == item.person_only)
        assert(type(en[id].name) == "string")
        assert(not en[id].name:find("[\128-\255]"))
        assert(item.name ~= en[id].name)
    end
    local translated = 0
    for _ in pairs(en) do translated = translated + 1 end
    assert(count == translated and count == 41)
    assert(zh.z_clean_stone.name == "净化符")
    assert(en.z_clean_stone.name == "Cleansing Token")
    LOC = nil
end)
return t.count
