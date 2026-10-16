-- BagIcons.lua – small coin marker on bag items that are on a sell list
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

if not addon then return end

local LOCAL_ICON = "Interface\\MoneyFrame\\UI-GoldIcon"
local GLOBAL_ICON = "Interface\\MoneyFrame\\UI-SilverIcon"

-- Bagnon item slots we have marked, so list changes can refresh them.
local bagnonSlots = setmetatable({}, { __mode = "k" })

local function GetSellIcon(itemID)
    if not addon.profile or not addon._charKey then return nil end

    local db = addon.char[addon._charKey]
    -- Global Keep overrides Sell, so such items are never marked.
    if addon.profile.globalKeepList[itemID] then return nil end

    if db and db.sellList and db.sellList[itemID] then
        return LOCAL_ICON
    elseif addon.profile.globalSellList[itemID] then
        return GLOBAL_ICON
    end
end

local function SetMarker(button, link)
    local marker = button.MyAutoVendorSellIcon
    local id = link and tonumber(link:match("item:(%d+)"))
    local icon = id and GetSellIcon(id)

    if not icon then
        if marker then marker:Hide() end
        return
    end

    if not marker then
        marker = button:CreateTexture(nil, "OVERLAY")
        marker:SetWidth(14)
        marker:SetHeight(14)
        marker:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.MyAutoVendorSellIcon = marker
    end

    marker:SetTexture(icon)
    marker:Show()
end

---------------------------------------------------------------------
-- BLIZZARD BAGS
---------------------------------------------------------------------
local function UpdateContainerFrame(frame)
    local bag = frame:GetID()
    local name = frame:GetName()
    for i = 1, frame.size or 0 do
        local button = _G[name .. "Item" .. i]
        if button then
            SetMarker(button, GetContainerItemLink(bag, button:GetID()))
        end
    end
end

hooksecurefunc("ContainerFrame_Update", UpdateContainerFrame)

---------------------------------------------------------------------
-- BAGNON
---------------------------------------------------------------------
local function UpdateBagnonSlot(slot)
    bagnonSlots[slot] = true
    -- Cached slots belong to other characters (Bagnon_Forever).
    if slot.IsCached and slot:IsCached() then
        SetMarker(slot, nil)
    else
        SetMarker(slot, slot:GetItem())
    end
end

local function HookBagnon()
    local Bagnon = LibStub("AceAddon-3.0"):GetAddon("Bagnon", true)
    if not Bagnon or not Bagnon.ItemSlot or Bagnon.ItemSlot.MyAutoVendorHooked then
        return
    end
    Bagnon.ItemSlot.MyAutoVendorHooked = true
    hooksecurefunc(Bagnon.ItemSlot, "Update", UpdateBagnonSlot)
end

HookBagnon()

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, name)
    if name == "Bagnon" then
        HookBagnon()
    end
end)

---------------------------------------------------------------------
-- REFRESH AFTER LIST CHANGES
---------------------------------------------------------------------
function addon:UpdateBagIcons()
    for i = 1, NUM_CONTAINER_FRAMES or 0 do
        local frame = _G["ContainerFrame" .. i]
        if frame and frame:IsShown() then
            UpdateContainerFrame(frame)
        end
    end

    for slot in pairs(bagnonSlots) do
        if slot:IsVisible() then
            UpdateBagnonSlot(slot)
        end
    end
end
