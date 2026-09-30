local t = dofile("tests/support.lua")
local previous_items = package.preload["enums/hh_items"]
local previous_templates = package.preload["widgets/redux/templates"]
local previous_class = Class

local grid_config
local function button()
    return { SetTextures = function() end, SetScale = function() end }
end
package.preload["widgets/redux/templates"] = function()
    return { ScrollingGrid = function(_, config)
        grid_config = config
        return {
            SetPosition = function() end,
            up_button = button(), down_button = button(),
            scroll_bar_line = { SetTexture = function() end, SetScale = function() end },
            position_marker = { SetTextures = function() end, SetScale = function() end,
                image = { SetTexture = function() end } },
        }
    end }
end
package.preload["enums/hh_items"] = function()
    return dofile("scripts/enums/hh_items.lua")
end
Class = function(_, ctor)
    return { _ctor = ctor }
end

local function gemName(language, id)
    LOC = { GetLocaleCode = function() return language end }
    package.loaded["enums/hh_items"] = nil
    package.loaded["widgets/hh_ui/hh_equip_ui"] = nil
    local ui = require("widgets/hh_ui/hh_equip_ui")
    ui.CreateTemplates({ hh_server_items = {} })
    local shown_name
    local gem_number = {
        SetString = function() end,
        GetRegionSize = function() return 1, 1 end,
        SetPosition = function() end,
    }
    local name = {
        gem_num = gem_number,
        SetString = function(_, value) shown_name = value end,
        GetRegionSize = function() return 1, 1 end,
        SetPosition = function() end,
    }
    local widget = {
        hh_background = {
            Hide = function() end,
            Show = function() end,
            hh_btn = { gem_name = name, SetOnClick = function() end },
        },
    }
    grid_config.apply_fn({}, widget, { id = id, num = 2 }, 1)
    return shown_name
end

t.test("Chinese forge displays original gem names", function()
    assert(gemName("zh", "durableGem") == "耐用宝珠:")
    assert(gemName("zh", "treasure_atk") == "宝★攻击:")
end)
t.test("English forge displays translated gem names", function()
    assert(gemName("en", "durableGem") == "Durability Gem:")
end)

Class = previous_class
package.preload["enums/hh_items"] = previous_items
package.preload["widgets/redux/templates"] = previous_templates
package.loaded["enums/hh_items"] = nil
package.loaded["widgets/hh_ui/hh_equip_ui"] = nil
package.loaded["widgets/redux/templates"] = nil
LOC = nil
return t.count
