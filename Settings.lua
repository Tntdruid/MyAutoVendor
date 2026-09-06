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

    frame:SetTitle("MyAutoVendor Settings")
    frame:SetStatusText("Indstillinger for auto-keep og item-level")
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
    left:SetTitle("Auto-keep regler")
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

    AddCheck("Behold consumables", "keepConsumables")
    AddCheck("Behold quest items", "keepQuest")
    AddCheck("Behold gear", "keepGear")
    AddCheck("Behold profession mats", "keepProfessionMats")

    ---------------------------------------------------------
    -- RIGHT GROUP (ITEM LEVEL)
    ---------------------------------------------------------
    local right = AceGUI:Create("InlineGroup")
    right:SetTitle("Item-level regler")
    right:SetWidth(220)
    right:SetLayout("List")
    frame:AddChild(right)

    local minSlider = AceGUI:Create("Slider")
    minSlider:SetLabel("Minimum Item Level")
    minSlider:SetSliderValues(0, 300, 1)
    minSlider:SetValue(rules.minIlvl)
    minSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.minIlvl = val
    end)
    right:AddChild(minSlider)
    sliders.minIlvl = minSlider

    local maxSlider = AceGUI:Create("Slider")
    maxSlider:SetLabel("Maximum Item Level")
    maxSlider:SetSliderValues(0, 300, 1)
    maxSlider:SetValue(rules.maxIlvl)
    maxSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.maxIlvl = val
    end)
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
    closeBtn:SetText("Luk")
    closeBtn:SetWidth(120)
    closeBtn:SetCallback("OnClick", function()
        frame:Hide()
    end)
    frame:AddChild(closeBtn)
end