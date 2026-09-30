local t = dofile("tests/support.lua")
local Star = require("components/hh_hat_star")
local function countSuccesses(level, padding_level, chance_override)
    local successes = 0
    local original_random = math.random
    local ok, err = pcall(function()
        for roll = 1,100 do
            math.random = function(low,high)
                assert(low == 1 and high == 100)
                return roll
            end
            local star = Star(t.entity())
            star.is_fixed_use = true
            star.star_num = level
            star.star_config = {[level+1]={test_material=1}}
            if chance_override ~= nil then
                star.GetStarUpChance = function() return chance_override end
            end
            local consumed, removed = 0,0
            local padding
            if padding_level then
                padding = t.entity()
                padding.components.hh_hat_star = Star(padding)
                padding.components.hh_hat_star.star_num = padding_level
                padding.Remove = function() removed = removed + 1 end
            end
            local container = {components={container={
                GetItemInSlot=function() return padding end,
                Has=function() return true end,
                ConsumeByName=function(_,name,num)
                    assert(name == "test_material" and num == 1)
                    consumed = consumed + num
                end,
            }}}
            local player = {components={hh_player={}},userid="test",name="Tester"}
            assert(star:AddStarByRpc(player,container))
            assert(consumed == 1)
            assert(removed == (padding_level and 1 or 0))
            if star.star_num == level + 1 then
                successes = successes + 1
            else
                assert(star.star_num == math.max(level-1,0))
            end
        end
    end)
    math.random = original_random
    assert(ok,err)
    return successes
end
t.test("all ten base probabilities match exactly across 100 outcomes", function()
    for next_level, chance in ipairs({90,80,70,60,50,45,40,35,25,17}) do
        assert(countSuccesses(next_level-1) == chance)
    end
end)
t.test("padding increases probability and is consumed on either outcome", function()
    for next_level, chance in ipairs({90,80,70,60,50,45,40,35,25,17}) do
        assert(countSuccesses(next_level-1,10) == math.min(chance+17,100))
    end
end)
t.test("zero and guaranteed success boundaries", function()
    for _, chance in ipairs({-10,0,1,100,110}) do
        assert(countSuccesses(0,nil,chance) == math.max(0,math.min(chance,100)))
    end
end)
return t.count
