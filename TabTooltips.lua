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
        GameTooltip:AddLine("Keep‑liste", 1, 0.85, 0)
        GameTooltip:AddLine("Items i denne liste bliver", 1, 1, 1)
        GameTooltip:AddLine("ALDRIG solgt – uanset regler.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Gælder kun denne character.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Sell‑liste", 1, 0.85, 0)
        GameTooltip:AddLine("Items i denne liste bliver solgt", 1, 1, 1)
        GameTooltip:AddLine("hver gang du åbner en merchant.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Kun for denne character.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL KEEP TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalKeep:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Global Keep‑liste", 1, 0.85, 0)
        GameTooltip:AddLine("Items i denne liste bliver", 1, 1, 1)
        GameTooltip:AddLine("ALDRIG solgt på nogen alt.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Delt mellem alle characters.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Global Sell‑liste", 1, 0.85, 0)
        GameTooltip:AddLine("Items i denne liste bliver solgt", 1, 1, 1)
        GameTooltip:AddLine("på ALLE dine alts.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Perfekt til fælles junk‑liste.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

end
