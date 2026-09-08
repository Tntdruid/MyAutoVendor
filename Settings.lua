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
    frame:SetStatusText("Auto-keep and item-level settings")
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
    left:SetTitle("Auto-keep rules")
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

    AddCheck("Keep consumables", "keepConsumables")
    AddCheck("Keep quest items", "keepQuest")
    AddCheck("Keep gear", "keepGear")
    AddCheck("Keep profession materials", "keepProfessionMats")

    ---------------------------------------------------------
    -- RIGHT GROUP (ITEM LEVEL)
    ---------------------------------------------------------
    local right = AceGUI:Create("InlineGroup")
    right:SetTitle("Item-level rules")
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
    minSlider:SetLabel("Minimum Item Level")
    minSlider:SetSliderValues(0, 300, 1)
    minSlider:SetValue(rules.minIlvl)
    minSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.minIlvl = val
    end)
    AddSliderTooltip(minSlider, "Items below this item level are sold automatically unless protected.")
    right:AddChild(minSlider)
    sliders.minIlvl = minSlider

    local maxSlider = AceGUI:Create("Slider")
    maxSlider:SetLabel("Maximum Item Level")
    maxSlider:SetSliderValues(0, 300, 1)
    maxSlider:SetValue(rules.maxIlvl)
    maxSlider:SetCallback("OnValueChanged", function(_, _, val)
        addon.char[addon._charKey].autoKeepRules.maxIlvl = val
    end)
    AddSliderTooltip(maxSlider, "Items above this item level are kept when gear auto-keep is enabled.")
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
    closeBtn:SetText("Close")
    closeBtn:SetWidth(120)
    closeBtn:SetCallback("OnClick", function()
        frame:Hide()
    end)
    frame:AddChild(closeBtn)
end