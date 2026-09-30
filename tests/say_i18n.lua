local t = dofile("tests/support.lua")
local utils = t.utils
local english = { hh_locale = "en" }
local chinese = { hh_locale = "zh" }

t.test("player speech uses their locale", function()
    assert(utils:LocalizeSay(english, "骑牛状态无法操作") == "Cannot use this while riding a beefalo.")
    assert(utils:LocalizeSay(chinese, "骑牛状态无法操作") == "骑牛状态无法操作")
    assert(utils:LocalizeSay(english, "消耗3个附魔石,最终转换个数:2") == "Used 3 enchantment stones; received 2.")
    assert(utils:LocalizeSay(english, "Something else") == "Something else")
end)

t.test("direct talker output translates without changing stored messages", function()
    local spoken
    local inst = { hh_locale = "en", components = { talker = { Say = function(_, value) spoken = value end } } }
    utils:HHSay(inst, "开始战斗吧")
    assert(spoken == "Let the battle begin!")
    inst.hh_locale = "zh"
    utils:HHSay(inst, "开始战斗吧")
    assert(spoken == "开始战斗吧")
end)

t.test("literal player messages all have English translations", function()
    local translations = dofile("scripts/enums/hh_say_en.lua")
    local paths = {
        "scripts/components/hh_player.lua", "scripts/components/hh_equip.lua",
        "main/hh_rpc.lua", "main/hh_ui.lua", "scripts/enums/hh_equip.lua",
        "scripts/enums/hh_prefabs.lua", "scripts/enums/hh_treasure_monster.lua",
    }
    local checked = 0
    for _, path in ipairs(paths) do
        local file = assert(io.open(path, "rb"))
        for line in file:lines() do
            local active = not line:match("^%s*%-%-")
            local candidate = ((path == "scripts/components/hh_player.lua" or path == "scripts/components/hh_equip.lua") and line:find("return", 1, true)) or line:find("HHSay(", 1, true) or line:find("HHSayV2(", 1, true)
            if active and candidate then
                for phrase in line:gmatch('"([^"]+)"') do
                    if phrase:find("[\128-\255]") and not phrase:find("%", 1, true) then
                        assert(type(translations[phrase]) == "string", path .. ": " .. phrase)
                        checked = checked + 1
                    end
                end
            end
        end
        file:close()
    end
    assert(checked > 100, checked)
end)

return t.count
