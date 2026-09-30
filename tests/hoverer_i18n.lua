local t = dofile("tests/support.lua")
local original = dofile("scripts/enums/hh_hoverer.lua")
local english = dofile("scripts/enums/hh_hoverer_en.lua")

t.test("every hover row has a matching English format", function()
    local count = 0
    for key, row in pairs(original) do
        local translated = english[key]
        assert(translated and type(translated.name) == "string")
        assert(type(translated.format) == "string")
        local _, original_args = row.format:gsub("%%s", "")
        local _, english_args = translated.format:gsub("%%s", "")
        assert(original_args == english_args, key)
        assert(not translated.name:find("[\128-\255]"))
        assert(not translated.format:find("[\128-\255]"))
        local ok = pcall(string.format, translated.format, "1", "2", "3", "4", "5")
        assert(ok, key)
        count = count + 1
    end
    assert(count > 45)
end)

t.test("all socketed gem descriptions are available in English", function()
    local count = 0
    for id, description in pairs(english.gems) do
        assert(type(id) == "string" and type(description) == "string")
        assert(not description:find("[\128-\255]"))
        count = count + 1
    end
    assert(count == 28)
end)

return t.count
