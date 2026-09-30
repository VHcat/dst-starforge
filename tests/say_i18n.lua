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

return t.count
