local t = dofile("tests/support.lua")
local Logs = require("components/hh_world_log")
LOC = { GetLocaleCode = function() return "en" end }
local render = require("utils/hh_log_i18n").Render

t.test("new world logs retain event data for local rendering", function()
    local logs = Logs(t.entity())
    logs:AddLog("treasure", "old server text", "dig_treasure_monster", {
        data_player = "Wendy", data_image = "pigman", data_monster = "大猪知非",
    })
    local entry = logs:GetLogs()[1]
    assert(entry.log_key == "dig_treasure_monster")
    assert(entry.log_data.data_monster == "大猪知非")
    entry.log_time = "2026年09月30日 12时30分00秒"
    local result = render(entry)
    assert(result:find("2026-09-30 12:30:00", 1, true))
    assert(result:find("Zhifei the Pig", 1, true))
    assert(not result:find("大猪知非", 1, true))
end)

t.test("legacy world logs remain readable", function()
    assert(render({ ui_config = "old server text" }) == "old server text")
end)

return t.count
