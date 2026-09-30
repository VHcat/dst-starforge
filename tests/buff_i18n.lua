local t = dofile("tests/support.lua")
local english = dofile("scripts/enums/hh_buff_en.lua")

t.test("every defined buff has English UI text", function()
    local source = assert(io.open("scripts/enums/hh_buff.lua", "rb")):read("*a")
    local count = 0
    for line in source:gmatch("[^\n]+") do
        local id = line:match('^    %[%"([%w_]+)%"%] = {')
        if id then
            local entry = english[id]
            assert(entry and type(entry.name) == "string" and type(entry.desc) == "string", id)
            assert(not entry.desc:find("[\128-\255]"), id)
            count = count + 1
        end
    end
    assert(count == 30, count)
end)

return t.count
