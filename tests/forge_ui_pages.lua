local t = dofile("tests/support.lua")
local previous_class = Class
local previous_templates = package.preload["widgets/redux/templates"]
package.preload["widgets/redux/templates"] = function() return {} end
Class = function(_, ctor) return {} end
package.loaded["widgets/hh_ui/hh_equip_ui"] = nil
local ui = require("widgets/hh_ui/hh_equip_ui")

local function panel()
    local state = { shown = {}, slots = {} }
    local function page(name)
        return { Show = function() state.shown[name] = true end,
            Hide = function() state.shown[name] = false end }
    end
    local mock = { hh_main = {}, tabs = {}, enchant_page = page("enchant"),
        gems_page = page("gems"), storage_page = page("storage") }
    for _, name in ipairs({ "enchant", "gems", "storage" }) do
        mock.tabs[name] = { image = { SetTint = function() end } }
    end
    mock.container_widget = { inv = {} }
    for i = 1, 28 do
        mock.container_widget.inv[i] = {
            Show = function() state.slots[i] = true end,
            Hide = function() state.slots[i] = false end,
        }
    end
    return mock, state
end

t.test("forge pages expose only their own container slots", function()
    local mock, state = panel()
    local ranges = {
        enchant = function(i) return i >= 25 and i <= 27 end,
        gems = function(i) return i == 28 end,
        storage = function(i) return i <= 24 end,
    }
    for name, visible in pairs(ranges) do
        ui.SetPage(mock, name)
        for i = 1, 28 do assert(state.slots[i] == visible(i), name .. " slot " .. i) end
        for page_name, shown in pairs(state.shown) do assert(shown == (page_name == name)) end
    end
end)

Class = previous_class
package.preload["widgets/redux/templates"] = previous_templates
package.loaded["widgets/hh_ui/hh_equip_ui"] = nil
package.loaded["widgets/redux/templates"] = nil
return t.count
