local t = dofile("tests/support.lua")
local notice = dofile("scripts/enums/hh_notice_en.lua")

t.test("global mod announcements translate without losing values", function()
    local translated = notice.Translate("Wendy将装备提升至7★")
    assert(translated == "Wendy upgraded equipment to 7 stars.")
    translated = notice.Translate("Wendy好运当头，合成出:超超超稀有的寒冰之力", function()
        return "Ice Power"
    end)
    assert(translated == "Lucky Wendy crafted an exceptionally rare Ice Power!")
    translated = notice.Translate("猪人掉落特殊装备包裹", nil, "Pigman")
    assert(translated == "Pigman dropped a special equipment bundle.")
end)

t.test("unknown announcements remain readable", function()
    assert(notice.Translate("An external mod message") == "An external mod message")
    assert(notice.Translate(nil) == "")
end)

return t.count
