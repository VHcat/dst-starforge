local t = dofile("tests/support.lua")
local utils = t.utils
package.preload["enums/hh_buff"] = function()
    return { test_buff = {} }
end
local Buff = require("components/hh_buff")
TheNet = { IsServerPaused = function() return false end }

local rpc_calls = {}
local serialization_calls = 0
utils.TableToStr = function(_, buffs)
    serialization_calls = serialization_calls + 1
    return next(buffs) and "active" or "empty"
end
utils.HHClientRpc = function(_, _, key, value)
    rpc_calls[#rpc_calls + 1] = { key, value }
end

local function entity(is_player)
    local inst = { components = {}, tasks = {}, update_starts = 0, update_stops = 0 }
    function inst:HasTag(tag) return is_player and tag == "player" end
    function inst:ListenForEvent() end
    function inst:StartUpdatingComponent() self.update_starts = self.update_starts + 1 end
    function inst:StopUpdatingComponent() self.update_stops = self.update_stops + 1 end
    function inst:DoPeriodicTask(_, fn)
        local task = { callback = fn, cancelled = false }
        function task:Cancel() self.cancelled = true end
        self.tasks[#self.tasks + 1] = task
        return task
    end
    return inst
end

t.test("inactive player buffs schedule no synchronization", function()
    local inst = entity(true)
    Buff(inst)
    assert(#inst.tasks == 0)
    assert(serialization_calls == 0)
end)

t.test("player buff synchronization starts and stops with buffs", function()
    local inst = entity(true)
    local buff = Buff(inst)
    assert(buff:AddBuff("test_buff", 10))
    assert(#inst.tasks == 1 and not inst.tasks[1].cancelled)
    assert(rpc_calls[#rpc_calls][2] == "active")
    local before = #rpc_calls
    inst.tasks[1].callback()
    assert(#rpc_calls == before + 1)
    assert(buff:RemoveBuff("test_buff"))
    assert(inst.tasks[1].cancelled and inst.hh_buff_tips == nil)
    assert(inst.update_stops == 1)
    assert(rpc_calls[#rpc_calls][2] == "empty")
end)

t.test("expired buffs stop synchronization", function()
    local inst = entity(true)
    local buff = Buff(inst)
    assert(buff:AddBuff("test_buff", 1))
    local task = inst.tasks[1]
    buff:OnUpdate(2)
    assert(task.cancelled and inst.hh_buff_tips == nil)
    assert(buff.start_update == false)
    assert(rpc_calls[#rpc_calls][2] == "empty")
end)

t.test("monster buffs never serialize or schedule client synchronization", function()
    local inst = entity(false)
    local buff = Buff(inst)
    local before = serialization_calls
    assert(buff:AddBuff("test_buff", 10))
    assert(#inst.tasks == 0 and serialization_calls == before)
    buff:RemoveBuff("test_buff")
    assert(serialization_calls == before)
end)

t.test("table comparison detects nested and extra values", function()
    assert(utils:HHCompareTable({ a = { 1, 2 }, b = false }, { b = false, a = { 1, 2 } }))
    assert(not utils:HHCompareTable({ a = { 1, 2 } }, { a = { 1, 3 } }))
    assert(not utils:HHCompareTable({ a = 1 }, { a = 1, b = 2 }))
end)

return t.count
