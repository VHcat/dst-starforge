local Widget = require("widgets/widget")
local TEMPLATES = require("widgets/redux/templates")
local ImageButton = require("widgets/imagebutton")
local HH_UTILS = require("utils/hh_utils")
local HH_ITEMS_CONFIG = require("enums/hh_items")

local main_xml, main_tex = "images/global.xml", "square.tex"
local close_xml, close_tex = "images/crafting_menu.xml", "pinslot_unpin_button.tex"
local image_size = 64
local panel_width, panel_height = 450, 340
local pages = { "enchant", "gems", "storage" }
local page_labels = { "page_enchant", "page_gems", "page_storage" }
local gold = { 216 / 255, 180 / 255, 74 / 255, 1 }

local function makeTextButton(parent, label, position, width, onClick)
    local button = HH_UTILS:HHCreateImageButton(parent, main_xml, main_tex, position, width / image_size, 30 / image_size, { 0.16, 0.13, 0.10, 0.95 })
    button.hh_text = HH_UTILS:HHCreateTextUi(button, Vector3(0, 0, 1), label, nil, 18)
    button:SetOnClick(onClick)
    return button
end

local HH_UI = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_equip_ui")
    self.owner = owner
    self.hh_server_items = {}
    self.page = "enchant"
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.hh_main = HH_UTILS:CreateFrameUiTwo(self.root, Vector3(0, 0, 1), {
        size_x = panel_width, size_y = panel_height, color = { 41 / 255, 30 / 255, 21 / 255, 0.96 },
    })
    self.hh_main.hh_title = HH_UTILS:HHCreateTextUi(self.hh_main, Vector3(0, 145, 1), HH_UTILS:GetLanguageByKey("equip_ui", "title"), gold, 28)
    self.hh_main.hh_close = HH_UTILS:HHCreateImageButton(self.hh_main, close_xml, close_tex, Vector3(211, 151, 1), 0.3, 0.3)
    self.hh_main.hh_close:SetOnClick(function()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
    end)
    self.tabs = {}
    for i, page in ipairs(pages) do
        self.tabs[page] = makeTextButton(self.hh_main, HH_UTILS:GetLanguageByKey("equip_ui", page_labels[i]), Vector3((i - 2) * 140, 108, 1), 130, function()
            self:SetPage(page)
        end)
    end

    self.enchant_page = self.hh_main:AddChild(Widget("enchant_page"))
    local labels = { { -130, "equip_slot" }, { -30, "enchant_slot" }, { 70, "cleanse_slot" } }
    for _, entry in ipairs(labels) do
        HH_UTILS:HHCreateTextUi(self.enchant_page, Vector3(entry[1], 69, 1), HH_UTILS:GetLanguageByKey("equip_ui", entry[2]), gold, 20)
    end
    local upgrade = makeTextButton(self.enchant_page, HH_UTILS:GetLanguageByKey("equip_ui", "upgrade"), Vector3(-130, -40, 1), 92, function()
        self:CreateSureUi("UpdateEffectValue", HH_UTILS:GetLanguageByKey("equip_ui", "reroll_confirm"), nil, false)
    end)
    local enchant = makeTextButton(self.enchant_page, HH_UTILS:GetLanguageByKey("equip_ui", "enchant"), Vector3(-30, -40, 1), 92, function()
        self:CreateSureUi("AddEquipEffect", HH_UTILS:GetLanguageByKey("equip_ui", "enchant_confirm"), nil, false)
    end)
    local clear = makeTextButton(self.enchant_page, HH_UTILS:GetLanguageByKey("equip_ui", "clear"), Vector3(70, -40, 1), 92, function()
        self:CreateSureUi("RemoveEquipEffect", HH_UTILS:GetLanguageByKey("equip_ui", "clear_confirm"), nil, false)
    end)
    HH_UTILS:UiAddFocusStr(upgrade, HH_UTILS:GetLanguageByKey("equip_ui", "reroll_hint"), 18)
    HH_UTILS:UiAddFocusStr(enchant, HH_UTILS:GetLanguageByKey("equip_ui", "enchant_hint"), 18)
    HH_UTILS:UiAddFocusStr(clear, HH_UTILS:GetLanguageByKey("equip_ui", "clear_hint"), 18)
    HH_UTILS:HHCreateTextUi(self.enchant_page, Vector3(0, -105, 1), HH_UTILS:GetLanguageByKey("equip_ui", "enchant_quick_hint"), nil, 19)

    self.gems_page = self.hh_main:AddChild(Widget("gems_page"))
    HH_UTILS:HHCreateTextUi(self.gems_page, Vector3(-75, 70, 1), HH_UTILS:GetLanguageByKey("equip_ui", "gem_title"), gold, 23)
    HH_UTILS:HHCreateTextUi(self.gems_page, Vector3(155, 68, 1), HH_UTILS:GetLanguageByKey("equip_ui", "gem_target"), gold, 19)
    HH_UTILS:HHCreateTextUi(self.gems_page, Vector3(155, -62, 1), HH_UTILS:GetLanguageByKey("equip_ui", "gem_quick_hint"), nil, 17)
    self.hh_main.hh_gem_ui = self.gems_page
    self.gems_page.gem_templates = self.gems_page:AddChild(self:CreateTemplates())
    self.gems_page.gem_templates:SetPosition(-65, -22, 1)

    self.storage_page = self.hh_main:AddChild(Widget("storage_page"))
    self.storage_page.put_in = makeTextButton(self.storage_page, HH_UTILS:GetLanguageByKey("equip_ui", "put_in"), Vector3(-80, -145, 1), 130, function()
        self:CreateSureUi("MoveEquips", HH_UTILS:GetLanguageByKey("equip_ui", "move_confirm"), nil, false)
    end)
    self.storage_page.dismantle = makeTextButton(self.storage_page, HH_UTILS:GetLanguageByKey("equip_ui", "dismantle"), Vector3(80, -145, 1), 130, function()
        self:CreateSureUi("RemoveEquips", HH_UTILS:GetLanguageByKey("equip_ui", "dismantle_confirm"), nil, true)
    end)
    self:UpdateTemplates()
    self.inst:ListenForEvent("hh_items", function() self:UpdateTemplates() end, self.owner)
    self:SetPage("enchant")
end)

function HH_UI:SetContainerWidget(container_widget)
    self.container_widget = container_widget
    self:SetPage(self.page)
end

function HH_UI:SetPage(page)
    if page ~= "enchant" and page ~= "gems" and page ~= "storage" then return end
    self.page = page
    HH_UTILS:HHKillChild(self.hh_main, "hh_sure_ui")
    self.enchant_page:Hide()
    self.gems_page:Hide()
    self.storage_page:Hide()
    self[page .. "_page"]:Show()
    for tab_page, button in pairs(self.tabs) do
        button.image:SetTint(tab_page == page and gold[1] or 0.16, tab_page == page and gold[2] or 0.13, tab_page == page and gold[3] or 0.10, 0.95)
    end
    if self.container_widget and self.container_widget.inv then
        for i, slot in ipairs(self.container_widget.inv) do
            local visible = (page == "storage" and i <= 24)
                or (page == "enchant" and i >= 25 and i <= 27)
                or (page == "gems" and i == 28)
            if visible then slot:Show() else slot:Hide() end
        end
    end
end

function HH_UI:UpdateTemplates()
    if self["hh_main"]
            and self["hh_main"]["hh_gem_ui"]
            and self["hh_main"]["hh_gem_ui"]["gem_templates"]
            and HH_UTILS:HasComponents(self["owner"], "hh_client")
    then
        local hh_items_client = self["owner"]["components"]["hh_client"]:GetValue("hh_items")
        if HH_UTILS:IsHHType(hh_items_client, "table") then
            self["hh_server_items"] = hh_items_client
            self["hh_main"]["hh_gem_ui"]["gem_templates"]:SetItemsData(self["hh_server_items"])
        end
    end
end
function HH_UI:CreateTemplates()
    local child_size_x, child_size_y = 270, 30

    ----滑轮每一个子类(每次滑动会刷新 index代表可见的条数)
    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)
        widget:SetOnGainFocus(
                function()
                    if self["hh_main"] and self["hh_main"]["hh_gem_ui"] and self["hh_main"]["hh_gem_ui"]["gem_templates"] then
                        self["hh_main"]["hh_gem_ui"]["gem_templates"]:OnWidgetFocus(widget)
                    end
                end
        )
        ----任务条
        widget["hh_background"] = HH_UTILS:HHCreateImageUi(widget, main_xml, main_tex, Vector3(0, 0, 1), 10, 10, { 0, 0, 0, 0 })
        widget["hh_background"]["hh_btn"] = widget["hh_background"]:AddChild(ImageButton(main_xml, main_tex))
        widget["hh_background"]["hh_btn"]["image"]:SetTint(0, 0, 0, 0.5)
        widget["hh_background"]["hh_btn"]:SetNormalScale(child_size_x / image_size, child_size_y / image_size, 1)
        widget["hh_background"]["hh_btn"]:SetPosition(0, 0, 1)
        widget["hh_background"]["hh_btn"]["focus_scale"] = { child_size_x / image_size, child_size_y / image_size, 1 }
        widget["hh_background"]["hh_btn"]["gem_name"] = HH_UTILS:HHCreateTextUi(widget["hh_background"]["hh_btn"], Vector3(0, 0, 1), HH_UTILS:GetLanguageByKey("equip_ui", "gem"), nil, 20)
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"] = HH_UTILS:HHCreateTextUi(widget["hh_background"]["hh_btn"]["gem_name"], Vector3(0, 0, 1), HH_UTILS:GetLanguageByKey("equip_ui", "gem"), nil, 20)
        return widget
    end

    local function ApplyDataToWidget(context, widget, data, index)
        widget["data"] = data
        widget["hh_background"]:Hide()
        if not data then
            return
        end
        widget["hh_background"]:Show()
        local hh_gem_list = widget["data"]
        local gem_id = hh_gem_list["id"]
        if not gem_id or not HH_ITEMS_CONFIG[gem_id] then
            return
        end
        local gem_name = HH_ITEMS_CONFIG[gem_id]["name"] or gem_id
        local gem_num = hh_gem_list["num"] or "0"
        widget["hh_background"]["hh_btn"]["gem_name"]:SetString(gem_name .. ":")
        local gem_name_size_x, gem_name_size_y = widget["hh_background"]["hh_btn"]["gem_name"]:GetRegionSize()
        widget["hh_background"]["hh_btn"]["gem_name"]:SetPosition(-child_size_x / 2 + 10 + gem_name_size_x / 2, 0, 1)
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:SetString(gem_num)
        local gem_num_size_x, gem_num_size_y = widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:GetRegionSize()
        widget["hh_background"]["hh_btn"]["gem_name"]["gem_num"]:SetPosition(gem_name_size_x / 2 + gem_num_size_x / 2, 0, 1)
        widget["hh_background"]["hh_btn"]:SetOnClick(function()
            local btn_desc = HH_UTILS:GetLanguageByKey("equip_ui", "socket_confirm")
            if gem_id == "a_punchStone" then
                btn_desc = HH_UTILS:GetLanguageByKey("equip_ui", "punch_confirm")
            elseif gem_id == "a_stoneDecoder" then
                btn_desc = HH_UTILS:GetLanguageByKey("equip_ui", "remove_gem_confirm")
            elseif HH_ITEMS_CONFIG[gem_id]["is_item"] then
                btn_desc = string.format(HH_UTILS:GetLanguageByKey("equip_ui", "use_item"), gem_name)
            else
                btn_desc = btn_desc .. "\n" .. gem_name
            end
            --重置宝石无法进行操作
            if gem_id == "a_refreshStone" or gem_id == "z_clean_stone" then
                return
            end
            self:CreateSureUi("EquipGems", btn_desc, gem_id, true)
        end)

    end
    local grid = TEMPLATES.ScrollingGrid(
            self["hh_server_items"],
            {
                context = {},
                ----单个子类长宽
                widget_width = child_size_x,
                widget_height = child_size_y,
                ----可视行数(滚动条的高度除以单个任务条宽度)
                num_visible_rows = 5,
                ----显示列数
                num_columns = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 5,
                scrollbar_height_offset = 0,
                peek_percent = 0,
                allow_bottom_empty_row = true, -- it's hidden anyway
            })
    grid:SetPosition(0, 0, 1)
    grid["up_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid["up_button"]:SetScale(0.2)

    grid["down_button"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid["down_button"]:SetScale(-0.2)

    grid["scroll_bar_line"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
    grid["scroll_bar_line"]:SetScale(0.3)

    grid["position_marker"]:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid["position_marker"]["image"]:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid["position_marker"]:SetScale(0.3)
    return grid
end
----
---创建确认按钮
---@param rpc_name
---@param ui_desc
---@param gem_index
---@param need_sure_ui:是否需要确认页面
---
function HH_UI:CreateSureUi(rpc_name, ui_desc, gem_index, need_sure_ui)
    local size_x, size_y = 300, 120
    local btn_size_x, btn_size_y = 50, 30
    local sure_margins = 10
    local desc = tostring(ui_desc)
    HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
    if need_sure_ui then
        self["hh_main"]["hh_sure_ui"] = HH_UTILS:HHCreateImageUi(self["hh_main"], scrapbook_xml, "scrap_wide.tex", Vector3(0, 0, 1), size_x, size_y)
        local sure_ui = self["hh_main"]["hh_sure_ui"]

        sure_ui["hh_desc"] = HH_UTILS:HHCreateTextUi(sure_ui, Vector3(0, 0, 1), desc, nil, 25)
        local desc_size_x, desc_size_y = sure_ui["hh_desc"]:GetRegionSize()
        sure_ui["hh_desc"]:SetPosition(0, size_y / 2 - sure_margins - desc_size_y / 2, 1)

        local sure_pos_x, sure_pos_y = -size_x / 2 + sure_margins + btn_size_x / 2, -size_y / 2 + btn_size_y / 2 + sure_margins
        sure_ui["hh_sure"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(sure_pos_x, sure_pos_y, 1), btn_size_x / image_size, btn_size_y / image_size, { 0, 0, 0, 0.5 })
        sure_ui["hh_sure"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_sure"], Vector3(0, 0, 1), HH_UTILS:GetLanguageByKey("equip_ui", "confirm"), nil, 15)
        sure_ui["hh_sure"]:SetOnClick(function()
            SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], rpc_name, gem_index)
            HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
        end)

        local close_pos_x, close_pos_y = size_x / 2 - sure_margins - btn_size_x / 2, -size_y / 2 + btn_size_y / 2 + sure_margins
        sure_ui["hh_close"] = HH_UTILS:HHCreateImageButton(sure_ui, main_xml, main_tex, Vector3(close_pos_x, close_pos_y, 1), btn_size_x / image_size, btn_size_y / image_size, { 0, 0, 0, 0.5 })
        sure_ui["hh_close"]["hh_text"] = HH_UTILS:HHCreateTextUi(sure_ui["hh_close"], Vector3(0, 0, 1), HH_UTILS:GetLanguageByKey("equip_ui", "cancel"), nil, 15)
        sure_ui["hh_close"]:SetOnClick(function()
            HH_UTILS:HHKillChild(self["hh_main"], "hh_sure_ui")
        end)
    else
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_handle_equip"], rpc_name, gem_index)
    end
end
return HH_UI