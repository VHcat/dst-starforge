----
---信息面板
---
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local HH_UTILS = require("utils/hh_utils")
local hh_component_desc_list = require("enums/hh_hoverer")
local HH_I18N = require("utils/hh_i18n")
local hh_hoverer_en = require("enums/hh_hoverer_en")
local HH_EQUIP_BUFF_LIST = require("enums/hh_enchant")["HH_EQUIP_BUFF_LIST"]
local main_xml, main_tex = "images/global.xml", "square.tex"
local big_scale = 30--大
local medium_scale = 20--中
local small_scale = 15--小
local last_check_time = 0
local save_target
local text_scale = 20--文本大小缺省值
local extra_size = 15--信息框大小偏移
local icon_list = {
    "hh_icon_left_up",
    "hh_icon_right_up",
    "hh_icon_right_down",
    "hh_icon_left_down",
}
local tuning_pos_config = TUNING["HH_HOVERER_POS_CONFIG"]
----颜色配置表
local COLOR_CONFIG = TUNING["HH_COLOR_CONFIG"] or {}
local ICON_CONFIG = TUNING["HH_ICON_CONFIG"] or {}
local function getLocalizedItemName(item)
    if type(item) ~= "table" then return "Unknown item" end
    if type(item.custom_name) == "string" and item.custom_name ~= "" then
        return item.custom_name
    end
    local id = type(item.prefab) == "string" and string.upper(item.prefab) or ""
    return (STRINGS and STRINGS.NAMES and STRINGS.NAMES[id]) or item.fallback or "Unknown item"
end
local function getInputItem()
    local target = TheInput:GetHUDEntityUnderMouse()
    target = (target and target["widget"] and target["widget"]["parent"] and target["widget"]["parent"]["item"])
            or TheInput:GetWorldEntityUnderMouse() or nil
    return target
end

local function replaceColor(hh_color, hh_new, hh_index)
    if HH_UTILS:IsHHType(hh_new, "number")
            and HH_UTILS:IsHHType(hh_color, "table")
            and hh_color[hh_index]
    then
        hh_color[hh_index] = hh_new
    end
end
local function getClientConfig()
    local hh_client_config = {
        ["back_ground_config"] = { 7, 5 }, --索引2是1-10 防止小数交互发生变化
        ["frame_config"] = { 31, 10 }, --索引2是1-10 防止小数交互发生变化
        ["icon_config"] = { 1, 1, 1, 1 }, --四个角图标配置
        ["close_show"] = false, --展示面版
    }
    if TheSim then
        TheSim:GetPersistentString("hh_hoverer_config", function(load_success, data)
            if load_success and data ~= nil then
                hh_client_config = HH_UTILS:StrToTable(data)
            end
        end)
    end
    return hh_client_config
end
local function getIsShowConfig(config)
    if HH_UTILS:IsHHType(config, "table") then
        return config["close_show"]
    end
    return true
end
local HH_HOVERER_UI = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_hoverer_ui")
    self["owner"] = owner
    self["root"] = self:AddChild(Widget("ROOT"))
    self["root"]:SetVAnchor(ANCHOR_MIDDLE)
    self["root"]:SetHAnchor(ANCHOR_MIDDLE)
    self["root"]:SetPosition(0, 0, 0)
    self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self["hh_config"] = getClientConfig()
    --配置跟随目标
    local father_main = self["root"]
    if tuning_pos_config == 0 then
        father_main = self
    end
    self["hh_main"] = HH_UTILS:HHCreateImageUi(father_main, main_xml, main_tex, Vector3(0, 0, 1), 10, 10, { 1, 1, 1, 0.5 })
    self["inst"]:ListenForEvent("hh_hoverer_config", function()
        self["hh_config"] = getClientConfig()
    end, self["owner"])
    self["inst"]:ListenForEvent("hh_update_hoverer", function()
        self:UpdateHoverer()
    end, self["owner"])

    self:StartUpdating()
end)
function HH_HOVERER_UI:SetTargetName(name)
    if HH_UTILS:IsHHType(name, "string") then
        self["hh_hoverer_text"] = name
    end
end
----
---获取颜色
---
local function getFrameColor(self_config, ui_type)
    local frame_color = { 244 / 255, 255 / 255, 0 / 255, 1 }
    if HH_UTILS:IsHHType(self_config, "table")
            and HH_UTILS:IsHHType(self_config[ui_type], "table")
            and HH_UTILS:IsHHType(self_config[ui_type][1], "number")
            and HH_UTILS:IsHHType(self_config[ui_type][2], "number")
    then
        local color_index = self_config[ui_type][1]
        local rgb_a = self_config[ui_type][2]
        if COLOR_CONFIG[color_index] and HH_UTILS:IsHHType(COLOR_CONFIG[color_index]["color"], "table") then
            frame_color[1] = COLOR_CONFIG[color_index]["color"][1] / 255
            frame_color[2] = COLOR_CONFIG[color_index]["color"][2] / 255
            frame_color[3] = COLOR_CONFIG[color_index]["color"][3] / 255
            frame_color[4] = rgb_a / 10
        end
    end
    return frame_color
end
local function createFrame(father, id, pos, size_x, size_y, self_config)
    if not father[id] then
        father[id] = father:AddChild(Image("images/hh_icon/hh_ui_frame.xml", "hh_ui_frame.tex"))
    end
    father[id]:SetPosition(pos)
    local frame_color = getFrameColor(self_config, "frame_config")
    father[id]:SetTint(frame_color[1], frame_color[2], frame_color[3], frame_color[4])
    if id == "hh_frame_left" or id == "hh_frame_right" then
        father[id]:SetRotation(90)
        father[id]:SetSize(size_y, size_x)
    else
        father[id]:SetSize(size_x, size_y)
    end
end
----
---边角图标
---
local function createFrameIcon(father, hh_id, pos, size_y, hh_angle, self_config)
    if not icon_list[hh_id] then
        return
    end
    local ui_id = icon_list[hh_id]
    if not HH_UTILS:IsHHType(self_config, "table")
            or not HH_UTILS:IsHHType(self_config["icon_config"], "table")
            or not HH_UTILS:IsHHType(self_config["icon_config"][hh_id], "number")
            or not HH_UTILS:IsHHType(ICON_CONFIG[self_config["icon_config"][hh_id]], "table")
    then
        return
    end
    if not father[ui_id] then
        father[ui_id] = father:AddChild(Image("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"))
    end
    local hh_icon_config = ICON_CONFIG[self_config["icon_config"][hh_id]]
    father[ui_id]:SetPosition(pos)
    --无图标需要变色
    if self_config["icon_config"][hh_id] == 1 then
        father[ui_id]:SetTexture("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex")
        local frame_color = getFrameColor(self_config, "frame_config")
        father[ui_id]:SetTint(frame_color[1], frame_color[2], frame_color[3], frame_color[4])
        father[ui_id]:SetSize(size_y, size_y)
        if HH_UTILS:IsHHType(hh_angle, "number") then
            father[ui_id]:SetRotation(hh_angle)
        end
    elseif hh_icon_config["xml"] and hh_icon_config["tex"] then
        father[ui_id]:SetTexture(hh_icon_config["xml"], hh_icon_config["tex"])
        --属性重置
        father[ui_id]:SetTint(1, 1, 1, 1)
        father[ui_id]:SetSize(30, 30)
        father[ui_id]:SetRotation(0)
    end
end

local function hh_update_ui_pos(main_ui, self_config)
    if not (main_ui and main_ui["GetSize"]) then
        return
    end
    local main_size_x, main_size_y = main_ui:GetSize()
    local pos = TheInput:GetScreenPosition()
    local scr_w, scr_h = TheSim:GetScreenSize()
    --起点在鼠标正上方
    local main_pos_x, main_pos_y = 0, main_size_y / 2
    --限制边框间距
    local limit_size = 100
    local pos_x_limit_min, pos_x_limit_max = limit_size, scr_w - limit_size
    local pos_y_limit_min, pos_y_limit_max = limit_size, scr_h - limit_size
    --超出屏幕往下偏移
    if pos["y"] > scr_h / 2 or pos["y"] + main_size_y > pos_y_limit_max then
        main_pos_y = -main_pos_y
    end
    --左右偏移
    local offset_x = 0
    if pos["x"] < scr_w / 2 and pos["x"] - pos_x_limit_min < main_size_x / 2 then
        offset_x = main_size_x / 2
    elseif pos["x"] > scr_w / 2 and pos_x_limit_max - pos["x"] < main_size_x / 2 then
        offset_x = -main_size_x / 2
    end
    main_pos_x = main_pos_x + offset_x
    local config_start_x, config_start_y = 0, 0
    --处理缩放大小 并且是偏移状态增加限制
    if tuning_pos_config == 1 then
        config_start_x, config_start_y = -500, 300
        main_ui:SetPosition(config_start_x + main_size_x / 2, config_start_y - main_size_y / 2, 1)
    elseif tuning_pos_config == 2 then
        config_start_x, config_start_y = -500, -280
        main_ui:SetPosition(config_start_x + main_size_x / 2, config_start_y + main_size_y / 2, 1)
        --elseif tuning_pos_config == 3 then
        --elseif tuning_pos_config == 4 then
    else
        main_ui:SetPosition(main_pos_x, main_pos_y, 1)
    end
    local frame_color = getFrameColor(self_config, "back_ground_config")
    if main_ui["SetTint"] then
        main_ui:SetTint(frame_color[1], frame_color[2], frame_color[3], frame_color[4])
    end
end

function HH_HOVERER_UI:UpdateHoverer()
    if not self["owner"] or not self["hh_main"] then
        return
    end
    local target = getInputItem()
    if not target or not target["GUID"] or not target["prefab"] or not target["components"] or target:HasTag("boat") then
        self["hh_main"]:Hide()
        self["hh_main"]:SetSize(10, 10)
        self["inst_more_info"] = nil
        return
    end
    if self["hh_main"]["shown"] then
        hh_update_ui_pos(self["hh_main"], self["hh_config"])
    end
    local target_infos = self["owner"]["hh_hoverer_list"]
    if not HH_UTILS:IsHHType(target_infos, "table") then
        return
    end
    if target_infos["hh_01_name"] and target_infos["hh_01_name"]["str"] then
        target_infos["hh_01_name"]["str"] = tostring(self["hh_target_name"])
    end
    local is_change = HH_UTILS:HHCompareTable(self["inst_more_info"], target_infos)
    if is_change then
        return
    end
    self["inst_more_info"] = target_infos
    -----------------------------------开始拆分数据-----------------------------------
    --记录最后的图片大小
    local hh_body_weight = 0
    local hh_body_height = 0
    --记录生成的ui信息
    local hh_body_ui_list = {}
    local main_ui = self["hh_main"]
    local body_keys = HH_UTILS:TableSortKeys(hh_component_desc_list)
    for i, v in ipairs(body_keys) do
        if target_infos[v] and target_infos[v]["bool"] == true and hh_component_desc_list[v] then
            local child_text_scale = hh_component_desc_list[v]["text_scale"] or text_scale
            local father_name = target_infos[v]["name"] or hh_component_desc_list[v]["name"] or "前缀未定义"--文本前缀
            local father_color = target_infos[v]["name_color"] or hh_component_desc_list[v]["name_color"] or { 1, 1, 1, 1 }
            local child_name = target_infos[v]["str"] or "后缀未定义"--详细信息
            local child_color = target_infos[v]["str_color"] or hh_component_desc_list[v]["str_color"] or { 1, 1, 1, 1 }--信息信息文本颜色
            if HH_I18N.GetLocale() == "en" and hh_hoverer_en[v] then
                local translated = hh_hoverer_en[v]
                father_name = translated.name
                local args = target_infos[v]["format_args"]
                if type(args) == "table" then
                    local ok, localized = pcall(string.format, translated.format, unpack(args))
                    if ok then
                        child_name = localized
                    end
                end
                if v == "hh_04_edible" then
                    local id = target_infos[v]["food_type_id"]
                    if type(args) == "table" and hh_hoverer_en.food_types[id] then
                        child_name = string.format(translated.format, hh_hoverer_en.food_types[id], args[2], args[3], args[4])
                    end
                elseif v == "hh_05_food_tag" then
                    local tags = target_infos[v]["tag_data"]
                    if type(tags) == "table" then
                        local parts = {}
                        for _, tag in ipairs(tags) do
                            local label = hh_hoverer_en.food_tags[tag.id]
                            if label then table.insert(parts, label .. tostring(tag.amount)) end
                        end
                        child_name = table.concat(parts, " ")
                    end
                elseif v == "hh_09_tool" then
                    local tools = target_infos[v]["tool_data"]
                    if type(tools) == "table" then
                        local parts = {}
                        for _, tool in ipairs(tools) do
                            local label = hh_hoverer_en.tool_types[tool.id]
                            if label then table.insert(parts, label .. " " .. tostring(tool.amount)) end
                        end
                        child_name = table.concat(parts, " ")
                    end
                elseif v == "hh_10_stackable" and type(args) == "table" and args[2] == "无上限" then
                    child_name = tostring(args[1]) .. "/Unlimited"
                elseif v == "hh_01_text" and type(GetDescription) == "function" then
                    local ok, local_description = pcall(GetDescription, self["owner"], target)
                    if ok and type(local_description) == "string" and local_description ~= "" then
                        if HH_UTILS:GetStringWordNum(local_description) > 20 then
                            local_description = HH_UTILS:SubStringUTF8(local_description, 1, 20) .. "..."
                        end
                        child_name = local_description
                    end
                elseif v == "hh_12_container" then
                    local items = target_infos[v]["container_items"]
                    if type(items) == "table" and type(args) == "table" then
                        local names = {}
                        for _, item in ipairs(items) do
                            local name = getLocalizedItemName(item)
                            if item.count then name = name .. "x" .. tostring(item.count) end
                            table.insert(names, name)
                        end
                        local suffix = #names > 0 and ("\nItems: " .. table.concat(names, " ")) or ""
                        if HH_UTILS:GetStringWordNum(suffix) > 40 then
                            suffix = HH_UTILS:SubStringUTF8(suffix, 1, 40) .. "..."
                        end
                        child_name = tostring(args[1]) .. "/" .. tostring(args[2]) .. suffix
                    end
                elseif v == "hh_14_unwrappable" then
                    local items = target_infos[v]["wrapped_items"]
                    if type(items) == "table" then
                        local lines = {}
                        for _, item in ipairs(items) do
                            local name = getLocalizedItemName(item)
                            if item.days then name = name .. " (" .. tostring(item.days) .. " days)" end
                            if item.count then name = name .. "x" .. tostring(item.count) end
                            table.insert(lines, name)
                        end
                        child_name = table.concat(lines, "\n")
                    end
                elseif v == "hh_15_stewer" then
                    local id = target_infos[v]["product_id"]
                    if type(id) == "string" and type(args) == "table" then
                        local name = STRINGS and STRINGS.NAMES and STRINGS.NAMES[string.upper(id)] or id
                        child_name = string.format(translated.format, name, args[2])
                    end
                elseif v == "hh_16_growable" then
                    local stage = target_infos[v]["stage_number"]
                    if stage and type(args) == "table" then
                        child_name = string.format(translated.format, tostring(stage), args[2])
                    end
                elseif v == "hh_30_cookable" then
                    local id = target_infos[v]["product_id"]
                    if type(id) == "string" then
                        child_name = STRINGS and STRINGS.NAMES and STRINGS.NAMES[string.upper(id)] or id
                    end
                elseif v == "hh_32_hh_equip_suit" then
                    local id = target_infos[v]["suit_id"]
                    child_name = hh_hoverer_en.suits[id] or child_name
                elseif v == "hh_34_boss_equip" and target_infos[v]["is_bound"] == false then
                    child_name = "Unbound"
                elseif v == "hh_18_insulator" then
                    local kind = target_infos[v]["insulation_kind"]
                    if kind == "warm" then father_name = "Warmth:" end
                    if kind == "cool" then father_name = "Cooling:" end
                elseif v == "hh_27_domesticatable" then
                    local parts = {}
                    if target_infos[v]["has_obedience"] then
                        table.insert(parts, string.format("Obedience: %s%%", target_infos[v]["obedience"] or 0))
                    end
                    if target_infos[v]["has_domestication"] then
                        table.insert(parts, string.format("Domestication: %s%%", target_infos[v]["domestication"] or 0))
                    end
                    if #parts > 0 then child_name = table.concat(parts, " ") end
                elseif v == "hh_28_dryer" then
                    local days = target_infos[v]["days"]
                    if days and target_infos[v]["dry_state"] == "drying" then
                        child_name = tostring(days) .. " days until dry"
                    elseif days and target_infos[v]["dry_state"] == "spoiling" then
                        child_name = tostring(days) .. " days until spoiled"
                    end
                elseif v == "hh_33_hh_follow" then
                    local values = target_infos[v]["follow_values"]
                    if type(values) == "table" then
                        child_name = string.format("Damage (%s) reduction (%s) critical (%s%%)", unpack(values))
                    end
                end
                if v == "hh_32_hh_gem" then
                    local id = target_infos[v]["affix_id"]
                    local config = type(id) == "string" and HH_EQUIP_BUFF_LIST[id] or nil
                    if config then
                        local desc = HH_I18N.GetAffixText(id, "desc", config["desc"])
                        if config["value_range"] then
                            local range = "(" .. tostring(config["value_range"]["min"]) .. "~" .. tostring(config["value_range"]["max"]) .. ")"
                            local ok, rendered = pcall(string.format, desc, range)
                            if ok then child_name = rendered end
                        else
                            child_name = desc
                        end
                    elseif target_infos[v]["gem_count"] then
                        local used = target_infos[v]["gem_count"]
                        local current = target_infos[v]["gem_current_limit"] or 0
                        local maximum = target_infos[v]["gem_max_limit"] or current
                        child_name = tostring(used) .. "/" .. tostring(current)
                        if current < maximum then
                            child_name = child_name .. "; " .. tostring(maximum - current) .. " unopened"
                        end
                    end
                elseif v == "hh_32_hh_monster" then
                    local data = target_infos[v]["effect_data"]
                    if type(data) == "table" and type(data.buffs) == "table" then
                        local lines = {}
                        if data.day_bonus then
                            table.insert(lines, string.format("Health bonus by day: %s (%s x %s)", data.day_bonus, data.day_rate, data.day_count))
                        else
                            table.insert(lines, "Daily health bonus unavailable")
                        end
                        for _, buff in ipairs(data.buffs) do
                            local format = hh_hoverer_en.monster_formats[buff.key] or buff.fallback
                            if format then
                                local ok, rendered = pcall(string.format, format, tostring(buff.value))
                                if ok then table.insert(lines, rendered) end
                            end
                        end
                        child_name = table.concat(lines, "\n")
                    end
                elseif v == "hh_32_hh_player" then
                    local data = target_infos[v]["effect_data"]
                    if type(data) == "table" then
                        local lines = {}
                        for _, effect in ipairs(data) do
                            local format = hh_hoverer_en.player_formats[effect.id]
                            if format then
                                local ok, rendered = pcall(string.format, format, tostring(effect.value))
                                if ok then table.insert(lines, rendered) end
                            end
                        end
                        child_name = table.concat(lines, "\n")
                    end
                elseif v == "hh_32_hh_gem_check" then
                    local source = target_infos["hh_32_hh_gem"]
                    local id = source and source["affix_id"]
                    local config = type(id) == "string" and HH_EQUIP_BUFF_LIST[id] or nil
                    if config then
                        child_name = HH_I18N.GetAffixText(id, "check", config["check_desc"])
                    end
                end
            end
            if not main_ui["hh_body_" .. v] then
                main_ui["hh_body_" .. v] = HH_UTILS:HHCreateTextUi(main_ui, Vector3(0, 0, 1), "", { 1, 1, 1, 1 }, child_text_scale)
            end
            --详细信息
            if not main_ui["hh_body_" .. v]["hh_str"] then
                main_ui["hh_body_" .. v]["hh_str"] = HH_UTILS:HHCreateTextUi(main_ui["hh_body_" .. v], Vector3(0, 0, 1), "", { 1, 1, 1, 1 }, child_text_scale, true)
            end
            main_ui["hh_body_" .. v]:SetString(father_name)
            main_ui["hh_body_" .. v]:SetColour(father_color)
            --靠左
            main_ui["hh_body_" .. v]["hh_str"]:SetString(child_name)
            main_ui["hh_body_" .. v]["hh_str"]:SetColour(child_color)
            local name_size_x, name_size_y = main_ui["hh_body_" .. v]:GetRegionSize()
            local str_size_x, str_size_y = main_ui["hh_body_" .. v]["hh_str"]:GetRegionSize()
            --子类左对齐 父类置空字符串
            if father_name == "" and target_infos[v]["child_ui"] then
                name_size_x, name_size_y = 1, name_size_y
            end
            if child_name == "" and target_infos[v]["child_ui"] then
                str_size_x, str_size_y = 0, 0
            end
            main_ui["hh_body_" .. v]["hh_str"]:SetPosition(name_size_x / 2 + str_size_x / 2, name_size_y / 2 - str_size_y / 2)
            --特殊ui部分处理
            HH_UTILS:HHKillChild(main_ui["hh_body_" .. v]["hh_str"], "hh_child_ui")
            --登记附属ui大小
            local hh_child_ui_size_x, hh_child_ui_size_y = 0, 0
            if target_infos[v]["child_ui"] and type(target_infos[v]["child_ui"]) == "table" and #target_infos[v]["child_ui"] > 0 then
                --只是一个父类 方便上级区分和kill
                main_ui["hh_body_" .. v]["hh_str"]["hh_child_ui"] = main_ui["hh_body_" .. v]["hh_str"]:AddChild(Image())
                local extra_child_ui = main_ui["hh_body_" .. v]["hh_str"]["hh_child_ui"]
                --锁定为描述文字左下角方便处理后续ui坐标
                extra_child_ui:SetPosition(-str_size_x / 2, -str_size_y / 2, 1)
                local child_pos_y = 0
                for ci, cv in ipairs(target_infos[v]["child_ui"]) do
                    if HH_UTILS:IsHHType(cv, "table") then
                        local extra_image_weight, extra_image_height = 0, 0
                        local extra_text_weight, extra_text_height = 0
                        if cv["tex"] and cv["xml"] then
                            extra_child_ui["hh_image_" .. ci] = HH_UTILS:HHCreateImageUi(extra_child_ui, cv["xml"], cv["tex"], Vector3(0, 0, 1), text_scale, text_scale)
                            local extra_image_size_x, extra_image_size_y = extra_child_ui["hh_image_" .. ci]:GetSize()
                            extra_child_ui["hh_image_" .. ci]:SetPosition(extra_image_size_x / 2, child_pos_y - extra_image_size_y / 2, 1)
                            extra_image_weight, extra_image_height = extra_image_size_x, extra_image_size_y
                        end
                        if cv["desc"] then
                            local description = cv["desc"]
                            if HH_I18N.GetLocale() == "en" then
                                if v == "hh_32_hh_gem" and type(cv["name"]) == "string" then
                                    description = hh_hoverer_en.gems[cv["name"]] or description
                                elseif v == "hh_32_hh_equip" and type(cv["name"]) == "table" then
                                    local buff = cv["name"]
                                    local id = buff["name"]
                                    local config = type(id) == "string" and HH_EQUIP_BUFF_LIST[id] or nil
                                    if config then
                                        local name = HH_I18N.GetAffixText(id, "name", config["name"])
                                        local desc = HH_I18N.GetAffixText(id, "desc", config["desc"])
                                        if buff["value"] then
                                            local ok, rendered = pcall(string.format, desc, buff["value"])
                                            if ok then desc = rendered end
                                            local maximum = config["value_range"] and config["value_range"]["max"]
                                            if maximum and buff["value"] == maximum then
                                                desc = desc .. " (maxed)"
                                            elseif maximum and buff["value"] > maximum then
                                                desc = desc .. " (beyond limit)"
                                            end
                                        end
                                        description = name .. ":" .. desc
                                    end
                                end
                            end
                            extra_child_ui["hh_text_" .. ci] = HH_UTILS:HHCreateTextUi(extra_child_ui, Vector3(0, 0, 1), description, cv["desc_color"] or { 1, 1, 1, 1 }, text_scale, true)
                            local extra_text_size_x, extra_text_size_y = extra_child_ui["hh_text_" .. ci]:GetRegionSize()
                            --需要兼容图片部分
                            extra_child_ui["hh_text_" .. ci]:SetPosition(extra_image_weight + extra_text_size_x / 2, child_pos_y - extra_text_size_y / 2, 1)
                            extra_text_weight, extra_text_height = extra_text_size_x, extra_text_size_y
                        end
                        child_pos_y = child_pos_y - math["max"](extra_image_height, extra_text_height)
                        hh_child_ui_size_x = math["max"](hh_child_ui_size_x, extra_image_weight + extra_text_weight)
                        hh_child_ui_size_y = hh_child_ui_size_y + math["max"](extra_image_height, extra_text_height)
                    end
                end
            end
            str_size_y = str_size_y + hh_child_ui_size_y
            --信息信息坐标(名字需要单独处理 不然会导致多行动作显示偏右边)
            if v == "hh_01_name" then
                main_ui["hh_body_" .. v]["hh_str"]:SetPosition(str_size_x / 2 - name_size_x / 2, name_size_y / 2 - str_size_y / 2)
            end
            hh_body_weight = math["max"](hh_body_weight, (name_size_x + str_size_x), hh_child_ui_size_x)
            hh_body_height = hh_body_height + math["max"](name_size_y, str_size_y)
            local pos_y = -name_size_y / 2
            if str_size_y < name_size_y * 1.5 then
                pos_y = -math["max"](name_size_y, str_size_y) / 2
            end
            -- pos_x pos_y 最终ui需要偏移的坐标差
            table["insert"](hh_body_ui_list, { id = "hh_body_" .. v, pos_x = name_size_x / 2, pos_y = pos_y, size_y = math["max"](name_size_y, str_size_y) })
        else
            HH_UTILS:HHKillChild(main_ui, "hh_body_" .. v)
        end
    end
    --处理物品图标
    HH_UTILS:HHKillChild(main_ui, "hh_item_image")
    main_ui["hh_item_image"] = main_ui:AddChild(Image())
    if HH_UTILS:HasReplica(target, "inventoryitem") then
        local item_image_size = text_scale * 2
        local image_xml = target["replica"]["inventoryitem"]:GetAtlas()
        local image_tex = target["replica"]["inventoryitem"]:GetImage()
        if image_xml and image_tex then
            main_ui["hh_item_image"]:SetTexture(image_xml, image_tex)
            main_ui["hh_item_image"]:SetSize(item_image_size, item_image_size)
            --处理调料
            if target["inv_image_bg"] and target["inv_image_bg"]["atlas"] and target["inv_image_bg"]["image"] then
                local spiced_xml, spiced_tex = target["inv_image_bg"]["atlas"], target["inv_image_bg"]["image"]
                main_ui["hh_item_image"]:SetTexture(spiced_xml, spiced_tex)
                main_ui["hh_item_image"]:SetSize(item_image_size, item_image_size)
                if target:HasTag("spicedfood") then
                    local hh_xml, hh_tex = target["replica"]["inventoryitem"]:GetAtlas(), target["replica"]["inventoryitem"]:GetImage()
                    if hh_xml and hh_tex then
                        main_ui["hh_item_image"]["hh_spiced_image"] = main_ui["hh_item_image"]:AddChild(Image())
                        main_ui["hh_item_image"]["hh_spiced_image"]:SetTexture(hh_xml, hh_tex)
                        main_ui["hh_item_image"]["hh_spiced_image"]:SetSize(item_image_size, item_image_size)
                    end
                end
            end
            local item_size_x, item_size_y = main_ui["hh_item_image"]:GetSize()
            --只需要加宽
            hh_body_weight = hh_body_weight + item_size_x
        end
    end
    --开始处理坐标部分 y轴增加偏移 看着对称一点
    local start_x, start_y = -hh_body_weight / 2, hh_body_height / 2 - 5
    for i, v in ipairs(hh_body_ui_list) do
        local ui_id = v["id"]
        if ui_id and main_ui[ui_id] and v["pos_x"] and v["pos_y"] then
            local ui_offset_x, ui_offset_y = v["pos_x"], v["pos_y"]
            local size_y = v["size_y"] or 0
            main_ui[ui_id]:SetPosition(start_x + ui_offset_x, start_y + ui_offset_y / 2, 1)
            start_y = start_y - size_y
        end
    end
    --处理图标坐标
    if main_ui["hh_item_image"] then
        local item_size_x, item_size_y = main_ui["hh_item_image"]:GetSize()
        main_ui["hh_item_image"]:SetPosition(hh_body_weight / 2 - item_size_x / 2, hh_body_height / 2 - item_size_y / 2, 1)
    end
    hh_body_weight = hh_body_weight + extra_size
    hh_body_height = hh_body_height + extra_size
    self["hh_main"]:SetSize(hh_body_weight, hh_body_height)
    self["hh_main"]:Show()

    --增加边框
    local frame_size = 6
    local com_x, com_y = hh_body_weight / 2 + frame_size / 2, hh_body_height / 2 + frame_size / 2
    local com_size_x, com_size_y = hh_body_weight + frame_size * 2, hh_body_height + frame_size * 2
    createFrame(self["hh_main"], "hh_frame_left", Vector3(-com_x, 0, 1), frame_size, com_size_y, self["hh_config"])
    createFrame(self["hh_main"], "hh_frame_right", Vector3(com_x, 0, 1), frame_size, com_size_y, self["hh_config"])
    createFrame(self["hh_main"], "hh_frame_up", Vector3(0, com_y, 1), com_size_x, frame_size, self["hh_config"])
    createFrame(self["hh_main"], "hh_frame_down", Vector3(0, -com_y, 1), com_size_x, frame_size, self["hh_config"])
    --增加边角图标
    createFrameIcon(self["hh_main"], 1, Vector3(-com_x, com_y, 1), frame_size, nil, self["hh_config"])
    createFrameIcon(self["hh_main"], 2, Vector3(com_x, com_y, 1), frame_size, 90, self["hh_config"])
    createFrameIcon(self["hh_main"], 3, Vector3(com_x, -com_y, 1), frame_size, 180, self["hh_config"])
    createFrameIcon(self["hh_main"], 4, Vector3(-com_x, -com_y, 1), frame_size, 270, self["hh_config"])
    hh_update_ui_pos(self["hh_main"], self["hh_config"])
end
function HH_HOVERER_UI:OnUpdate(dt)
    if not self["owner"] or not self["hh_main"] then
        return
    end
    local show_config = getIsShowConfig(self["hh_config"])
    if show_config then
        self["hh_main"]:Hide()
        self["inst_more_info"] = nil
        save_target = nil
        return
    end
    local target = getInputItem()
    if not target or not target["GUID"] or not target["prefab"]
            or not target["components"] or target:HasTag("boat")
            or (target:HasTag("NOBLOCK") and target["prefab"] ~= "abigail")
    then
        self["hh_main"]:Hide()
        self["hh_main"]:SetSize(10, 10)
        self["inst_more_info"] = nil
        save_target = nil
        return
    end
    if self["hh_main"]["shown"] then
        hh_update_ui_pos(self["hh_main"], self["hh_config"])
    end
    --处理原官方文本
    if not (target ~= save_target or last_check_time + 1 < GetTime()
            or self["hh_target_name"] ~= self["hh_hoverer_text"]) then
        return
    end
    save_target = target
    self["hh_target_name"] = self["hh_hoverer_text"]
    last_check_time = GetTime()
    --鼠标指向玩家时 如果鼠标上没有物品则不显示面板 防止出显示bug
    if TheInput:GetWorldEntityUnderMouse() == self["owner"] and HH_UTILS:HasComponents(self["owner"], "playercontroller") then
        local lmb = self["owner"]["components"]["playercontroller"]:GetLeftMouseAction()
        if not lmb then
            self["hh_main"]:Hide()
            return
        end
    end
    --print("rpc")
    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_hoverer_server"], save_target, self["hh_target_name"])
end
return HH_HOVERER_UI