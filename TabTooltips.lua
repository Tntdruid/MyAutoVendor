-- TabTooltips.lua – MyAutoVendor
-- Multi-line tooltips til alle tabs

local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

function addon:SetupTabTooltips(tabKeep, tabSell, tabGlobalKeep, tabGlobalSell)

    ------------------------------------------------------------
    -- KEEP TAB TOOLTIP
    ------------------------------------------------------------
    tabKeep:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon:T("keepList"), 1, 0.85, 0)
        GameTooltip:AddLine(addon:T("itemsInList"), 1, 1, 1)
        GameTooltip:AddLine(addon:T("neverSold"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine(addon:T("appliesCharacter"), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon:T("sellList"), 1, 0.85, 0)
        GameTooltip:AddLine(addon:T("itemsSold"), 1, 1, 1)
        GameTooltip:AddLine(addon:T("soldAtMerchant"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine(addon:T("onlyCharacter"), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL KEEP TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalKeep:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon:T("globalKeepList"), 1, 0.85, 0)
        GameTooltip:AddLine(addon:T("itemsInList"), 1, 1, 1)
        GameTooltip:AddLine(addon:T("neverSold"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine(addon:T("sharedCharacters"), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon:T("globalSellList"), 1, 0.85, 0)
        GameTooltip:AddLine(addon:T("itemsSold"), 1, 1, 1)
        GameTooltip:AddLine(addon:T("allAlts"), 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine(addon:T("sharedJunk"), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

end
