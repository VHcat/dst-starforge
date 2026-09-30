local t = dofile("tests/support.lua")
local skins = dofile("scripts/enums/hh_skin.lua")
local english = dofile("scripts/enums/hh_skin_en.lua")

t.test("every configured skin has an English selector name", function()
    local count = 0
    for _, variants in pairs(skins) do
        for _, variant in ipairs(variants) do
            local source = variant.skin_name
            assert(type(source) == "string", tostring(source))
            local display = english[source] or source
            assert(not display:find("[\128-\255]"), tostring(source))
            count = count + 1
        end
    end
    assert(count > 30, count)
end)

return t.count
