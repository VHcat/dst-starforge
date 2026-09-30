local Widget = require("widgets/widget")
local HH_UTILS = require("utils/hh_utils")

local HH_LAUNCHER = Class(Widget, function(self, owner, help_ui, settings_ui)
    Widget._ctor(self, "hh_launcher")
    self.owner = owner
    self.help_ui = help_ui
    self.settings_ui = settings_ui
    self.focused_entry = nil
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetHAnchor(ANCHOR_LEFT)
    self.root:SetVAnchor(ANCHOR_BOTTOM)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.button = HH_UTILS:HHCreateImageButton(self.root, "images/crafting_menu_icons.xml", "filter_summer.tex", Vector3(80, 95, 1), 0.15, 0.15)
    self.button.hh_text = HH_UTILS:HHCreateTextUi(self.button, Vector3(0, -23, 1), HH_UTILS:GetLanguageByKey("ui", "launcher_label"), nil, 16)
    self.menu = self.button:AddChild(Widget("hh_launcher_menu"))
    self.menu:Hide()

    local function cancelHide()
        if self.hide_task then
            self.hide_task:Cancel()
            self.hide_task = nil
        end
    end
    local function showMenu()
        cancelHide()
        self.menu:Show()
    end
    local function hideMenuSoon()
        cancelHide()
        self.hide_task = self.inst:DoTaskInTime(0.45, function()
            self.hide_task = nil
            if not self.button.focus and not self.focused_entry then
                self.menu:Hide()
            end
        end)
    end
    local oldGainFocus = self.button.OnGainFocus
    local oldLoseFocus = self.button.OnLoseFocus
    self.button.OnGainFocus = function(...)
        if oldGainFocus then oldGainFocus(...) end
        showMenu()
    end
    self.button.OnLoseFocus = function(...)
        if oldLoseFocus then oldLoseFocus(...) end
        hideMenuSoon()
    end
    self.button:SetOnClick(function()
        cancelHide()
        self.menu:Hide()
        self:ClosePanels()
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_ui_container"])
    end)
    HH_UTILS:MakeUiCanMove(self.button)

    -- Secondary actions appear on hover; the forge remains one click away.
    local entries = {
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
        local oldEntryGain = button.OnGainFocus
        local oldEntryLose = button.OnLoseFocus
        button.OnGainFocus = function(...)
            if oldEntryGain then oldEntryGain(...) end
            self.focused_entry = button
            showMenu()
        end
        button.OnLoseFocus = function(...)
            if oldEntryLose then oldEntryLose(...) end
            if self.focused_entry == button then self.focused_entry = nil end
            hideMenuSoon()
        end
        button:SetOnClick(function()
            cancelHide()
            self.focused_entry = nil
            self.menu:Hide()
            entry[4]()
        end)
    end
end)

function HH_LAUNCHER:ClosePanels()
    HH_UTILS:HHKillChild(self.help_ui, "hh_main")
    if self.settings_ui.hh_main_ui then self.settings_ui:CreateMainUi() end
end

return HH_LAUNCHER
