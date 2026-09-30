local t = dofile("tests/support.lua")
local Logs = require("components/hh_world_log")
local logs = Logs(t.entity())
for i = 1,250 do
    logs.logs[i] = {id=i,log_type={i % 2 == 0 and "even" or "odd"}}
end
t.test("default page is capped and newest first", function()
    local page = logs:GetLogs()
    assert(#page == 100 and page[1].id == 250 and page[100].id == 151)
    page[1].log_type[1] = "changed"
    assert(logs.logs[250].log_type[1] == "even")
end)
t.test("pagination and filters preserve order", function()
    local page = logs:GetLogs(nil,100,2)
    assert(#page == 100 and page[1].id == 150 and page[100].id == 51)
    page = logs:GetLogs("even",100,2)
    assert(#page == 25 and page[1].id == 50 and page[25].id == 2)
    assert(#logs:GetLogs("missing") == 0)
    assert(#logs:GetLogs("",100,3) == 50)
end)
t.test("malformed pagination never reaches arithmetic", function()
    for _, value in ipairs({"oops",false,{},0,-1,0.5,math.huge,-math.huge,0/0}) do
        assert(#logs:GetLogs(nil,value,1) == 0)
        assert(#logs:GetLogs(nil,100,value) == 0)
    end
    assert(#logs:GetLogs({},100,1) == 0)
end)
t.test("oversized requests are bounded", function()
    assert(#logs:GetLogs(nil,100000,1) == 100)
    assert(#logs:GetLogs(nil,1,1e300) == 0)
end)
t.test("empty logs return empty result", function()
    assert(#Logs(t.entity()):GetLogs(nil,"oops",{}) == 0)
end)
return t.count
