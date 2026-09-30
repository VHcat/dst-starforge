local Widget = require("widgets/widget")
local HH_UTILS = require("utils/hh_utils")

local HH_LAUNCHER = Class(Widget, function(self, owner, help_ui, settings_ui)
    Widget._ctor(self, "hh_launcher")
    self.owner = owner
    self.help_ui = help_ui
    self.settings_ui = settings_ui
    self.menu_open = false
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetHAnchor(ANCHOR_LEFT)
    self.root:SetVAnchor(ANCHOR_BOTTOM)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.button = HH_UTILS:HHCreateImageButton(self.root, "images/crafting_menu_icons.xml", "filter_summer.tex", Vector3(80, 95, 1), 0.15, 0.15)
    self.button.hh_text = HH_UTILS:HHCreateTextUi(self.button, Vector3(0, -23, 1), HH_UTILS:GetLanguageByKey("ui", "launcher_label"), nil, 16)
    HH_UTILS:UiAddFocusStr(self.button, HH_UTILS:GetLanguageByKey("ui", "launcher_hint"), 20)
    self.button:SetOnClick(function()
        self.menu_open = not self.menu_open
        if self.menu_open then self.menu:Show() else self.menu:Hide() end
    end)
    HH_UTILS:MakeUiCanMove(self.button)
    -- As a child of the draggable button, the menu follows its position.
    self.menu = self.button:AddChild(Widget("hh_launcher_menu"))
    local entries = {
        { "images/crafting_menu_icons.xml", "filter_summer.tex", HH_UTILS:GetLanguageByKey("ui", "open_forge_label"), function()
            self:ClosePanels()
            SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
        end },
        { "images/button_icons.xml", "newsletter.tex", HH_UTILS:GetLanguageByKey("help_ui", "open_label"), function()
            if self.settings_ui.hh_main_ui then self.settings_ui:CreateMainUi() end
            if self.help_ui.hh_main then
                HH_UTILS:HHKillChild(self.help_ui, "hh_main")
            else
                self.help_ui:CreateMainUi()
            end
        end },
        { "images/crafting_menu_icons.xml", "filter_modded.tex", HH_UTILS:GetLanguageByKey("hover_config", "open_label"), function()
            HH_UTILS:HHKillChild(self.help_ui, "hh_main")
            self.settings_ui:CreateMainUi()
        end },
    }
    for i, entry in ipairs(entries) do
        local y = i * 48
        local button = HH_UTILS:HHCreateImageButton(self.menu, "images/global.xml", "square.tex", Vector3(58, y, 1), 165 / 64, 42 / 64, { 41 / 255, 30 / 255, 21 / 255, 0.92 })
        button.hh_icon = HH_UTILS:HHCreateImageUi(button, entry[1], entry[2], Vector3(-58, 0, 1), 28, 28)
        button.hh_icon:SetClickable(false)
        button.hh_text = HH_UTILS:HHCreateTextUi(button, Vector3(17, 0, 1), entry[3], nil, 20)
        button:SetOnClick(function()
            self.menu_open = false
            self.menu:Hide()
            entry[4]()
        end)
    end
    self.menu:Hide()
end)

function HH_LAUNCHER:ClosePanels()
    HH_UTILS:HHKillChild(self.help_ui, "hh_main")
    if self.settings_ui.hh_main_ui then self.settings_ui:CreateMainUi() end
end

return HH_LAUNCHER
