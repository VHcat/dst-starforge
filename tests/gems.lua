local t = dofile("tests/support.lua")
local Equip = require("components/hh_equip")
local config = require("enums/hh_enchant").HH_GEM_BUFF_LIST
local function setup()
    return setmetatable({inst=t.entity(),gems_list={"gem_a","gem_b"}},Equip)
end
local function withRandom(fn,body)
    local original = math.random
    math.random = fn
    local ok, err = pcall(body)
    math.random = original
    assert(ok,err)
end
t.test("specified first and last gem remove only that gem", function()
    withRandom(function() error("specified removal must not roll") end, function()
        for index = 1,2 do
            local e = setup()
            local ended = {}
            config.gem_a.end_fn = function() table.insert(ended,"gem_a") end
            config.gem_b.end_fn = function() table.insert(ended,"gem_b") end
            assert(e:ReduceGemByIndex(nil,index))
            assert(#e.gems_list == 1 and e.gems_list[1] == (index == 1 and "gem_b" or "gem_a"))
            assert(#ended == 1 and ended[1] == (index == 1 and "gem_a" or "gem_b"))
        end
    end)
end)
t.test("malformed indices never mutate equipment or advance RNG", function()
    withRandom(function() error("invalid removal must not roll") end, function()
        for _, index in ipairs({false,true,"1",{},0,-1,1.5,3,math.huge,-math.huge,0/0}) do
            local e = setup()
            assert(not e:ReduceGemByIndex(nil,index))
            assert(#e.gems_list == 2 and e.gems_list[1] == "gem_a" and e.gems_list[2] == "gem_b")
        end
    end)
end)
t.test("omitted index still performs random removal", function()
    local rolls = 0
    withRandom(function(low,high)
        assert(low == 1 and high == 2)
        rolls = rolls + 1
        return 2
    end, function()
        local e = setup()
        assert(e:ReduceGemByIndex(nil,nil))
        assert(rolls == 1 and #e.gems_list == 1 and e.gems_list[1] == "gem_a")
    end)
end)
t.test("duplicate gems lose only one copy", function()
    local e = setup()
    e.gems_list = {"gem_a","gem_a"}
    local ended = 0
    config.gem_a.end_fn = function() ended = ended + 1 end
    assert(e:ReduceGemByIndex(nil,2))
    assert(#e.gems_list == 1 and ended == 1)
end)
t.test("empty equipment cannot remove gems", function()
    local e = setup()
    e.gems_list = {}
    assert(not e:ReduceGemByIndex(nil,nil))
end)
return t.count
