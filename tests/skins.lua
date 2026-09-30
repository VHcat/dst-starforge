local t = dofile("tests/support.lua")
local Skin = require("components/hh_skin")
SendModRPCToClient = function() end
CLIENT_MOD_RPC = {hh_rpc={hh_save_skin={}}}
t.test("invalid client records preserve usable state", function()
    for _, record in ipairs({true,false,1,"oops",{}, {index=false},{index="2"},
            {index=0},{index=-1},{index=1.5},{index=3},{index=math.huge},{index=0/0}}) do
        local skin = Skin(t.entity())
        local original = skin.skin_data.test_item
        skin:UpdateClientValue({test_item=record})
        assert(skin.skin_data.test_item == original)
        local target = {prefab="test_item",GUID=42}
        assert(skin:ToolChangeSkin(target))
        assert(target.g_skin_index == 1)
        assert(skin:ToolChangeSkin(target))
        assert(target.g_skin_index == 2)
    end
end)
t.test("valid saved preference uses server limits and ignores client identity", function()
    local skin = Skin(t.entity())
    local record = {index=2,max_index=100000,target_uid=42,extra={}}
    skin:UpdateClientValue({test_item=record,unknown={index=1}})
    local accepted = skin.skin_data.test_item
    assert(accepted.index == 2 and accepted.max_index == 2)
    assert(accepted.target_uid == nil and accepted.extra == nil)
    assert(skin.skin_data.unknown == nil)
    record.index = 1
    assert(accepted.index == 2)
    local target = {prefab="test_item",GUID=42}
    assert(skin:ToolChangeSkin(target) and target.g_skin_index == 2)
    assert(skin:ToolChangeSkin(target) and target.g_skin_index == 1)
end)
t.test("invalid outer values are ignored", function()
    local skin = Skin(t.entity())
    skin:UpdateClientValue(nil)
    skin:UpdateClientValue(false)
    skin:UpdateClientValue("bad")
    assert(skin.skin_data.test_item.index == 1)
end)
return t.count
