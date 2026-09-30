local HH_I18N = require("utils/hh_i18n")

local monster_names = {
    ["大猪知非"] = "Zhifei the Pig", ["双持林猪"] = "Dual-wielding Lin Pig",
    ["超级猫悠"] = "Super Cat King", ["坎普斯大王"] = "Krampus King",
    ["星空蛋"] = "Starry Egg", ["月后巨鹿"] = "Lunar Deerclops",
    ["月后座狼"] = "Lunar Varg", ["装甲熊獾"] = "Armored Bearger",
    ["超级鲨鱼"] = "Super Shark", ["超级巨鹿"] = "Super Deerclops",
    ["超级熊大"] = "Super Bearger", ["附身狼王"] = "Possessed Varg",
    ["笨比林猪"] = "Lin Pig",
}
local gem_names = {
    ["宝★攻击"] = "Treasure Attack", ["宝★暴击"] = "Treasure Critical",
    ["宝★回耐"] = "Treasure Durability Regen",
}

local LogI18N = {}

function LogI18N.Render(entry)
    if type(entry) ~= "table" then return "" end
    if type(entry.log_key) ~= "string" or type(entry.log_data) ~= "table" then
        return entry.ui_config or ""
    end
    local template = HH_I18N.GetText("log", entry.log_key)
    local data = entry.log_data
    local english = HH_I18N.GetLocale() == "en"
    local result = template:gsub("{{([^{}]+)}}", function(key)
        local value = data[key]
        if english then
            if key == "data_effect" and type(data.data_effect_id) == "string" then
                value = HH_I18N.GetAffixText(data.data_effect_id, "name", value)
            elseif key == "data_monster" then
                value = monster_names[value] or value
            elseif key == "data_gem" then
                value = gem_names[value] or value
            end
        end
        return (type(value) == "number" or type(value) == "string") and tostring(value) or ""
    end)
    local date = tostring(entry.log_time or "")
    if english then
        date = date:gsub("(%d+)年(%d+)月(%d+)日 (%d+)时(%d+)分(%d+)秒", "%1-%2-%3 %4:%5:%6")
    end
    return "#" .. date .. ":white:25" .. result
end

return LogI18N
