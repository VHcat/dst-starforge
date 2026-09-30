local HH_UTILS = require("utils/hh_utils")

local function hh_ui_container(inst)
    if not HH_UTILS:NotIsDead(inst) or inst:HasTag("playerghost") then
        return
    end
    if inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding() then
        HH_UTILS:HHSay(inst, "骑牛状态无法操作")
        return
    end

    HH_UTILS:AddCdTask(inst, "hh_job_container_cd", 0.3,
            function(player)
                HH_UTILS:HHSay(player, "点太快了")
            end,
            function(player)
                if not HH_UTILS:HasComponents(player, "hh_job") then
                    return
                end
                player["components"]["hh_job"]:OpenContainer()
            end, inst)
end
AddModRPCHandler("hh_rpc", "hh_job_container", hh_ui_container)
