local ADDON_NAME = ...
local addon = _G[ADDON_NAME]
local AceGUI = LibStub("AceGUI-3.0")

function addon:OpenSettingsWindow()
    if addon.SettingsWindow then
        addon.SettingsWindow:RefreshValues()
        addon.SettingsWindow:Show()
        return
    end

    local frame = AceGUI:Create("Frame")
    addon.SettingsWindow = frame

    frame:SetTitle(addon:T("settings"))
    frame:SetStatusText(addon:T("settingsStatus"))
    frame:SetLayout("Flow")
    frame:SetWidth(480)
    frame:SetHeight(420)
    frame:EnableResize(false)

    local rules = addon.char[addon._charKey].autoKeepRules
    local checkboxes = {}
    local sliders = {}

    ---------------------------------------------------------
    -- LEFT GROUP (AUTO KEEP RULES)
    ---------------------------------------------------------
    local left = AceGUI:Create("InlineGroup")
    left:SetTitle(addon:T("autoKeepRules"))
    left:SetWidth(220)
    left:SetLayout("List")
    frame:AddChild(left)

    local function AddCheck(label, key)
        local chk = AceGUI:Create("CheckBox")
        chk:SetLabel(label)
        chk:SetValue(rules[key])
        chk:SetCallback("OnValueChanged", function(_, _, val)
            addon.char[addon._charKey].autoKeepRules[key] = val
        end)
        left:AddChild(chk)
        checkboxes[key] = chk
    end

    AddCheck(addon:T("keepConsumables"), "keepConsumables")
    AddCheck(addon:T("keepQuest"), "keepQuest")
    AddCheck(addon:T("keepGear"), "keepGear")
    AddCheck(addon:T("keepProfessionMats"), "keepProfessionMats")

    ---------------------------------------------------------
    -- RIGHT GROUP (ITEM LEVEL)
    ---------------------------------------------------------
    local right = AceGUI:Create("InlineGroup")
    right:SetTitle(addon:T("itemLevelRules"))
    right:SetWidth(220)
    right:SetLayout("List")
    frame:AddChild(right)

    local function AddSliderTooltip(slider, text)
        slider:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
            GameTooltip:SetText(text, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        slider:SetCallback("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    local minSlider = AceGUI:Create("Slider")
    minSlider:SetLabel(addon:T("minItemLevel"))
    minSlider:SetSliderValues(0, 300, 1)
    minSlider:SetValue(rules.minIlvl)
    minSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.minIlvl = val
    end)
    AddSliderTooltip(minSlider, addon:T("minTooltip"))
    right:AddChild(minSlider)
    sliders.minIlvl = minSlider

    local maxSlider = AceGUI:Create("Slider")
    maxSlider:SetLabel(addon:T("maxItemLevel"))
    maxSlider:SetSliderValues(0, 300, 1)
    maxSlider:SetValue(rules.maxIlvl)
    maxSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.maxIlvl = val
    end)
    AddSliderTooltip(maxSlider, addon:T("maxTooltip"))
    right:AddChild(maxSlider)
    sliders.maxIlvl = maxSlider

    function frame:RefreshValues()
        local currentRules = addon.char[addon._charKey].autoKeepRules
        for key, checkbox in pairs(checkboxes) do
            checkbox:SetValue(currentRules[key])
        end
        for key, slider in pairs(sliders) do
            slider:SetValue(currentRules[key])
        end
    end

    ---------------------------------------------------------
    -- CLOSE BUTTON
    ---------------------------------------------------------
    local closeBtn = AceGUI:Create("Button")
    closeBtn:SetText(addon:T("close"))
    closeBtn:SetWidth(120)
    closeBtn:SetCallback("OnClick", function()
        frame:Hide()
    end)
    frame:AddChild(closeBtn)
end