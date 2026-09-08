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
        GameTooltip:AddLine("Keep list", 1, 0.85, 0)
        GameTooltip:AddLine("Items in this list are", 1, 1, 1)
        GameTooltip:AddLine("NEVER sold, regardless of rules.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Applies only to this character.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Sell list", 1, 0.85, 0)
        GameTooltip:AddLine("Items in this list are sold", 1, 1, 1)
        GameTooltip:AddLine("every time you open a merchant.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Only for this character.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL KEEP TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalKeep:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Global keep list", 1, 0.85, 0)
        GameTooltip:AddLine("Items in this list are", 1, 1, 1)
        GameTooltip:AddLine("NEVER sold on any alt.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Shared across all characters.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalKeep:SetScript("OnLeave", function() GameTooltip:Hide() end)

    ------------------------------------------------------------
    -- GLOBAL SELL TAB TOOLTIP
    ------------------------------------------------------------
    tabGlobalSell:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Global sell list", 1, 0.85, 0)
        GameTooltip:AddLine("Items in this list are sold", 1, 1, 1)
        GameTooltip:AddLine("on ALL your alts.", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Perfect for a shared junk list.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    tabGlobalSell:SetScript("OnLeave", function() GameTooltip:Hide() end)

end
