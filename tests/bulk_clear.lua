local t = dofile("tests/support.lua")
local Equip = require("components/hh_equip")
local Player = require("components/hh_player")
local function setup(stones)
    local item = t.entity()
    local equip = setmetatable({inst = item, equip_buff_list = {{name="alpha"}, {name="beta"}}}, Equip)
    item.components.hh_equip = equip
    local player = setmetatable({inst=t.entity(), hh_items={z_clean_stone=stones},
        forge_container={components={container={GetItemInSlot=function() return item end}}},
        UpdateForgeEquipInfo=function() end}, Player)
    return player, equip
end
t.test("malformed selections cannot remove affixes or spend materials", function()
    for _, selection in ipairs({{true, 1}, {true, "yes"}, {foo=true}, {[0]=true},
            {[-1]=true}, {[1.5]=true}, {[math.huge]=true}, {[3]=true}, {false,false,false,false}}) do
        local p, e = setup(2)
        assert(not p:RemoveMoreEquipEffect(selection))
        assert(#e.equip_buff_list == 2 and p.hh_items.z_clean_stone == 2)
        assert(not e:ReduceMoreEquipBuff(selection))
        assert(#e.equip_buff_list == 2)
    end
end)
t.test("UI false placeholders remain compatible", function()
    local p,e = setup(1)
    assert(p:RemoveMoreEquipEffect({true,false,false,false}))
    assert(#e.equip_buff_list == 1 and e.equip_buff_list[1].name == "beta")
    assert(p.hh_items.z_clean_stone == 0)
end)
t.test("sparse selection removes and bills only selected affix", function()
    local p,e = setup(2)
    assert(p:RemoveMoreEquipEffect({[2]=true}))
    assert(#e.equip_buff_list == 1 and e.equip_buff_list[1].name == "alpha")
    assert(p.hh_items.z_clean_stone == 1)
end)
t.test("insufficient balance does not mutate equipment", function()
    local p,e = setup(1)
    assert(not p:RemoveMoreEquipEffect({true,true}))
    assert(#e.equip_buff_list == 2 and p.hh_items.z_clean_stone == 1)
end)
t.test("two removals cost exactly two stones", function()
    local p,e = setup(2)
    assert(p:RemoveMoreEquipEffect({true,true}))
    assert(#e.equip_buff_list == 0 and p.hh_items.z_clean_stone == 0)
end)
t.test("failed debit prevents removal", function()
    local p,e = setup(2)
    p.RemoveItemsByKey = function() return false end
    assert(not p:RemoveMoreEquipEffect({true}))
    assert(#e.equip_buff_list == 2 and p.hh_items.z_clean_stone == 2)
end)
t.test("failed removal refunds debit", function()
    local p,e = setup(2)
    e.ReduceMoreEquipBuff = function() return false,0,"failed" end
    assert(not p:RemoveMoreEquipEffect({true}))
    assert(#e.equip_buff_list == 2 and p.hh_items.z_clean_stone == 2)
end)
return t.count
