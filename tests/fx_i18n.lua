local t = dofile("tests/support.lua")
local english = dofile("scripts/enums/hh_language_en.lua").fx_text

t.test("all generated skill phrases have client-side English text", function()
    local file = assert(io.open("scripts/enums/hh_enchant.lua", "rb"))
    local source = file:read("*a")
    file:close()
    local block = assert(source:match('%["gem_jd"%] = {%s*(.-)%s*},'))
    local count = 0
    for phrase in block:gmatch('"([^"]+)"') do
        local translated = english[phrase]
        assert(type(translated) == "string" and not translated:find("[\128-\255]"), phrase)
        count = count + 1
    end
    assert(count == 50, count)
    for _, phrase in ipairs({ "治疗", "中毒", "格挡", "暴击", "穿刺", "永恒庇佑触发" }) do
        assert(type(english[phrase]) == "string", phrase)
    end
end)

return t.count
