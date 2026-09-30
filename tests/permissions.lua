local t = dofile("tests/support.lua")
local handlers = {}
AddModRPCHandler = function(namespace, name, fn) handlers[name] = fn end
dofile("job/hh_job_rpc.lua")

t.test("legacy item generation RPC is unavailable", function()
    assert(handlers.hh_special_limit == nil)
end)
t.test("ordinary job container RPC remains functional", function()
    local player = t.entity()
    player.components.health = { IsDead = function() return false end }
    local opened = false
    player.components.hh_job = { OpenContainer = function() opened = true end }
    handlers.hh_job_container(player)
    assert(opened)
end)
t.test("player component loads without the legacy account module", function()
    package.preload["enums/hh_local_host"] = function()
        error("Legacy account policy must not be loaded")
    end
    assert(require("components/hh_player"))
end)
return t.count
