local t = dofile("tests/support.lua")
local special = dofile("scripts/enums/hh_special_en.lua")

t.test("custom hover descriptions translate without changing source text", function()
    local title, description = special.Translate("特殊:", "右键寻找宝藏")
    assert(title == "Special:" and description == "Right-click to search for treasure.")
    title, description = special.Translate("宝藏:", "可以挖出甲虫猪")
    assert(title == "Treasure:" and description == "May reveal a beetle pig.")
end)

t.test("dynamic custom hover details keep their values", function()
    local title, description = special.Translate("炫彩特效:", "紫色法球(1/16)")
    assert(title == "Visual effect:" and description == "Purple Orb (1/16)")
    title, description = special.Translate("特殊强化:", "寒冰之力 火焰之力 ")
    assert(title == "Special upgrades:" and description == "Ice Power, Fire Power")
    STRINGS = { NAMES = { BIRD_EGG = "Egg" } }
    title, description = special.Translate("孵蛋:", "鸽子蛋(40秒)", { egg_id = "bird_egg", egg_seconds = 40 })
    assert(title == "Incubation:" and description == "Egg (40 seconds)")
end)

t.test("all treasure monster labels have English variants", function()
    local count = 0
    for _, label in pairs(special.treasure_titles) do
        assert(type(label) == "string" and #label > 0)
        count = count + 1
    end
    assert(count == 16, count)
    assert(special.treasure_titles["★★坦克猪猪★★\n超强的防御"]:find("Tank Pig", 1, true))
end)

return t.count
