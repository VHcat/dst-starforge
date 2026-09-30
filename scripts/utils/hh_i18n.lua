local chinese = require("enums/hh_language")
local english = require("enums/hh_language_en")

local I18N = {}

function I18N.GetLocale()
    if type(LOC) == "table" and type(LOC.GetLocaleCode) == "function"
            and LOC.GetLocaleCode() == "en" then
        return "en"
    end
    return "zh"
end

function I18N.GetText(section, key)
    if type(section) ~= "string" or type(key) ~= "string" then
        return "未定义"
    end
    local translated = I18N.GetLocale() == "en" and english[section] or nil
    local original = chinese[section]
    return (type(translated) == "table" and translated[key])
        or (type(original) == "table" and original[key])
        or "未定义"
end

function I18N.GetTable(section)
    if type(section) ~= "string" then
        return {}
    end
    if I18N.GetLocale() == "en" and type(english[section]) == "table" then
        return english[section]
    end
    return type(chinese[section]) == "table" and chinese[section] or {}
end

-- Affix IDs are gameplay/save identifiers; translations are read only at display time.
function I18N.GetAffixText(id, field, fallback)
    if I18N.GetLocale() == "en" and type(id) == "string" and type(field) == "string" then
        local affixes = english.affixes
        local entry = type(affixes) == "table" and affixes[id] or nil
        if type(entry) == "table" and type(entry[field]) == "string" then
            return entry[field]
        end
    end
    return fallback
end

return I18N
