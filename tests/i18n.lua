local t = dofile("tests/support.lua")
local previous_zh = package.preload["enums/hh_language"]
local previous_en = package.preload["enums/hh_language_en"]
package.loaded["utils/hh_i18n"] = nil
package.loaded["enums/hh_language"] = nil
package.loaded["enums/hh_language_en"] = nil
package.preload["enums/hh_language"] = function()
    return {sample={hello="你好",fallback="仅中文"},ui={help_title_intro="关于星砧"}}
end
package.preload["enums/hh_language_en"] = function()
    return {sample={hello="Hello"},ui={help_title_intro="About Starforge"}}
end
local i18n = require("utils/hh_i18n")
t.test("Chinese stays the default without game locale", function()
    LOC = nil
    assert(i18n.GetLocale() == "zh")
    assert(i18n.GetText("sample","hello") == "你好")
end)
t.test("English uses translation and falls back for missing keys", function()
    LOC = {GetLocaleCode=function() return "en" end}
    assert(i18n.GetLocale() == "en")
    assert(i18n.GetText("sample","hello") == "Hello")
    assert(i18n.GetText("sample","fallback") == "仅中文")
    assert(i18n.GetTable("ui").help_title_intro == "About Starforge")
end)
t.test("invalid lookup inputs and absent sections are safe", function()
    assert(i18n.GetText(nil,"hello") == "未定义")
    assert(i18n.GetText("sample",{}) == "未定义")
    assert(#i18n.GetTable("unknown") == 0)
    LOC = nil
end)
t.test("English help text preserves the rich-text syntax", function()
    local actual = dofile("scripts/enums/hh_language_en.lua")
    assert(#actual.mod_help > 50)
    for _, line in ipairs(actual.mod_help) do
        assert(type(line) == "string" and line:find(":",1,true))
        assert(not line:find(": ",1,true))
    end
end)
t.test("main UI dictionaries keep Chinese and English keys aligned", function()
    local zero = setmetatable({}, {__index=function() return 0 end})
    TUNING = {HH_CHANCE_CONFIG={DROP_EQUIP_CHANCE=zero,GIF_CHANCE=zero}}
    local zh = dofile("scripts/enums/hh_language.lua")
    TUNING = nil
    local en = dofile("scripts/enums/hh_language_en.lua")
    for _, section in ipairs({"ui","forge","equip_ui"}) do
        for key, value in pairs(zh[section]) do
            assert(type(value) == "string" and type(en[section][key]) == "string")
        end
    end
end)
t.test("modinfo follows the game's locale without changing option values", function()
    local function loadInfo(language)
        local env = {locale=language,ipairs=ipairs}
        local chunk = assert(loadfile("modinfo.lua"))
        setfenv(chunk,env)
        chunk()
        return env
    end
    local zh, en = loadInfo("zh"), loadInfo("en")
    assert(zh.name == "星砧 · 附魔强化")
    assert(en.name == "Starforge · Enchantment and Enhancement")
    assert(zh.configuration_options[1].label == "信息面版位置")
    assert(en.configuration_options[1].label == "Info panel position")
    assert(#zh.configuration_options == #en.configuration_options)
    local function hasNonAscii(value)
        return type(value) == "string" and value:find("[\128-\255]") ~= nil
    end
    for i, option in ipairs(zh.configuration_options) do
        local localized = en.configuration_options[i]
        assert(option.name == localized.name and option.default == localized.default)
        assert(not hasNonAscii(localized.label) and not hasNonAscii(localized.hover))
        assert(#option.options == #localized.options)
        for j, choice in ipairs(option.options) do
            assert(choice.data == localized.options[j].data)
            assert(not hasNonAscii(localized.options[j].description))
            assert(not hasNonAscii(localized.options[j].hover))
        end
    end
end)
package.preload["enums/hh_language"] = previous_zh
package.preload["enums/hh_language_en"] = previous_en
package.loaded["utils/hh_i18n"] = nil
package.loaded["enums/hh_language"] = nil
package.loaded["enums/hh_language_en"] = nil
return t.count
