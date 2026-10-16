-- ItemTooltip.lua – note in item tooltips showing which MyAutoVendor lists an item is on
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

if not addon then return end

local SELL_COLOR = { 1, 0.5, 0.25 }
local KEEP_COLOR = { 0.25, 1, 0.25 }

local function AddListLines(tooltip)
    if not addon.profile or not addon._charKey then return end

    local _, link = tooltip:GetItem()
    local id = link and tonumber(link:match("item:(%d+)"))
    if not id then return end

    local db = addon.char[addon._charKey]
    local lists = {
        { db.keepList,                  "keepList",       KEEP_COLOR },
        { addon.profile.globalKeepList, "globalKeepList", KEEP_COLOR },
        { db.sellList,                  "sellList",       SELL_COLOR },
        { addon.profile.globalSellList, "globalSellList", SELL_COLOR },
    }

    for _, entry in ipairs(lists) do
        local list, key, color = entry[1], entry[2], entry[3]
        if list and list[id] then
            tooltip:AddLine("MyAutoVendor: " .. addon:T(key), color[1], color[2], color[3])
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", AddListLines)
ItemRefTooltip:HookScript("OnTooltipSetItem", AddListLines)
