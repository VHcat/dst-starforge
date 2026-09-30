local t = dofile("tests/support.lua")
package.loaded["utils/hh_i18n"] = nil
package.loaded["enums/hh_language_en"] = nil
local i18n = require("utils/hh_i18n")
local english = dofile("scripts/enums/hh_language_en.lua")
t.test("localized affixes preserve original config and format placeholders", function()
    local original = {name="原名",client_text="中文",desc="增加%s点",check_desc="无"}
    LOC = {GetLocaleCode=function() return "en" end}
    local variable = 0
    for id, translation in pairs(english.affixes) do
        assert(type(id) == "string" and type(translation.name) == "string")
        assert(type(translation.short) == "string" and type(translation.desc) == "string")
        assert(type(translation.check) == "string")
        local name = i18n.GetAffixText(id,"name",original.name)
        local short = i18n.GetAffixText(id,"short",original.client_text)
        local desc = i18n.GetAffixText(id,"desc",original.desc)
        local requirement = i18n.GetAffixText(id,"check",original.check_desc)
        assert(name == translation.name and short == translation.short)
        assert(desc == translation.desc and requirement == translation.check)
        assert(not name:find("[\128-\255]") and not desc:find("[\128-\255]"))
        if desc:find("%%s") then
            assert(desc:find("%%s") and string.format(desc, 42):find("42",1,true))
            variable = variable + 1
        end
    end
    assert(variable >= 10)
    assert(original.name == "原名" and original.client_text == "中文")
    assert(i18n.GetAffixText("missing","name",original.name) == original.name)
end)
t.test("Chinese locale always uses the original display fields", function()
    LOC = {GetLocaleCode=function() return "zh" end}
    assert(i18n.GetAffixText("add_com_damage","name","额外伤害") == "额外伤害")
    LOC = nil
end)
return t.count
