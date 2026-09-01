-- Core.lua – MyAutoVendor (AzerothCore + Ace3)
local ADDON_NAME = ...
local MyAutoVendor = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceConsole-3.0",
    "AceEvent-3.0"
)
_G[ADDON_NAME] = MyAutoVendor

local AceDB = LibStub("AceDB-3.0")

local defaults = {
    profile = {
        autoKeepRules = {
            keepConsumables = true,
            keepQuest = true,
            keepGear = true,
            keepProfessionMats = true,
        },
        autoSell = true,
        minimap = {},
    },
    char = {}
}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function CharKey()
    return (UnitName("player") or "Unknown") .. "-" .. (GetRealmName() or "Realm")
end

local function toItemId(input)
    if not input then return nil end
    local n = tonumber(input)
    if n then return n end
    local id = tostring(input):match("item:(%d+)")
    return id and tonumber(id) or nil
end

local function SafeGetItemInfo(itemID)
    if not itemID then return nil,nil,nil,nil,nil,nil,nil end
    local ok, name, link, rarity, ilvl, minLevel, itemType, itemSubType, stack, equipLoc, icon =
        pcall(GetItemInfo, itemID)
    if ok and name then
        return name, link, itemType, itemSubType, icon, rarity, ilvl
    end
    return nil,nil,nil,nil,nil,nil,nil
end

local function FormatCopper(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100
    return string.format("%dg %ds %dc", g, s, c)
end

local function SaveMetaToChar(addon, listName, itemID, itemLink, icon)
    addon.char = addon.char or {}
    local key = addon._charKey or CharKey()
    addon.char[key] = addon.char[key] or { keepList = {}, sellList = {} }
    addon.char[key][listName][itemID] = addon.char[key][listName][itemID] or {
        ts = time(),
        link = itemLink or ("item:"..itemID),
        icon = icon
    }
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function MyAutoVendor:OnInitialize()
    self.db = AceDB:New("MyAutoVendorDB", defaults, true)
    self.profile = self.db.profile
    self.char = self.db.char or {}

    self._charKey = CharKey()
    self.char[self._charKey] = self.char[self._charKey] or {
        keepList = {},
        sellList = {}
    }

    self._undoStack = self._undoStack or {}
    self.activeTab = self.activeTab or "keep"

    self:RegisterChatCommand("mav", "HandleSlash")

    -- Minimap ikon
    self:SetupMinimap()
end

function MyAutoVendor:OnEnable()
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
end

---------------------------------------------------------------------
-- Minimap ikon
---------------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

function MyAutoVendor:SetupMinimap()
    if not LDB or not LDBIcon then return end

    self.db.profile.minimap = self.db.profile.minimap or {}

    local obj = LDB:NewDataObject("MyAutoVendor", {
        type = "data source",
        text = "MyAutoVendor",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",

        OnClick = function()
            if MyAutoVendor.ToggleUI then
                MyAutoVendor:ToggleUI()
            else
                print("MyAutoVendor: UI ikke indlæst endnu")
            end
        end,

        OnTooltipShow = function(tt)
            tt:AddLine("MyAutoVendor")
            tt:AddLine("Klik for at åbne addon", 1,1,1)
        end,
    })

    LDBIcon:Register("MyAutoVendor", obj, self.db.profile.minimap)
end

---------------------------------------------------------------------
-- AutoSell
---------------------------------------------------------------------
function MyAutoVendor:OnMerchantShow()
    if not self.profile.autoSell then return end

    local key = self._charKey
    local soldItems = {}
    local totalCopper = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemID = tonumber(link:match("item:(%d+)"))
                if itemID and self.char[key].sellList[itemID] then
                    local vendorPrice = select(11, GetItemInfo(link)) or 0
                    local _, count = GetContainerItemInfo(bag, slot)
                    count = tonumber(count) or 1
                    local value = vendorPrice * count
                    totalCopper = totalCopper + value
                    UseContainerItem(bag, slot)
                end
            end
        end
    end

    if totalCopper > 0 then
        self:Print("Solgte items for " .. FormatCopper(totalCopper))
    end
end

---------------------------------------------------------------------
-- Add / Remove / Undo
---------------------------------------------------------------------
function MyAutoVendor:AddItem(input)
    local id = toItemId(input)
    if not id then self:Print("Ugyldigt item input") return end

    local name, link, _,_,icon = SafeGetItemInfo(id)
    local listName = (self.activeTab == "sell") and "sellList" or "keepList"

    SaveMetaToChar(self, listName, id, link, icon)
    self:Print("Tilføjet " .. id .. " til " .. listName)

    if self.RefreshUI then pcall(self.RefreshUI, self) end
end

function MyAutoVendor:RemoveItem(input)
    local id = toItemId(input)
    if not id then self:Print("Ugyldigt item input") return end

    local key = self._charKey
    local listName = (self.activeTab == "sell") and "sellList" or "keepList"
    local list = self.char[key][listName]

    if list[id] then
        table.insert(self._undoStack, {
            id = id,
            meta = list[id],
            tab = self.activeTab,
            char = key
        })
        list[id] = nil
        self:Print("Fjernet " .. id .. " (kan fortrydes)")
        if self.RefreshUI then pcall(self.RefreshUI, self) end
    else
        self:Print("Item ikke fundet")
    end
end

function MyAutoVendor:Undo()
    local entry = table.remove(self._undoStack)
    if not entry then
        self:Print("Intet at fortryde")
        return
    end

    local key = entry.char
    local listName = (entry.tab == "sell") and "sellList" or "keepList"

    self.char[key][listName][entry.id] = entry.meta
    self:Print("Fortrudt fjernelse af " .. entry.id)

    if self.RefreshUI then pcall(self.RefreshUI, self) end
end

---------------------------------------------------------------------
-- CopyFromKey
---------------------------------------------------------------------
function MyAutoVendor:CopyFromKey(sourceKey)
    if not self.char[sourceKey] then
        self:Print("Ingen data for " .. sourceKey)
        return
    end

    local dest = self.char[self._charKey]
    dest.keepList = {}
    dest.sellList = {}

    for id, meta in pairs(self.char[sourceKey].keepList or {}) do
        dest.keepList[id] = meta
    end
    for id, meta in pairs(self.char[sourceKey].sellList or {}) do
        dest.sellList[id] = meta
    end

    self:Print("Kopieret fra " .. sourceKey)
    if self.RefreshUI then pcall(self.RefreshUI, self) end
end

---------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------
function MyAutoVendor:HandleSlash(msg)
    if msg == "" then
        self:Print("/mav ui")
        self:Print("/mav undo")
        self:Print("/mav copyfrom Name")
        return
    end

    local cmd, arg = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd:lower()

    if cmd == "ui" then
        if self.ToggleUI then self:ToggleUI() end
    elseif cmd == "undo" then
        self:Undo()
    elseif cmd == "copyfrom" then
        if arg and arg ~= "" then
            self:CopyFromKey(arg)
        else
            self:Print("Brug: /mav copyfrom Name-Realm")
        end
    else
        self:Print("Ukendt kommando")
    end
end

MyAutoVendor:Print("MyAutoVendor core loaded")
local ADDON_NAME = ...
MyAutoVendor = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0")

---------------------------------------------------------
-- INIT DB
---------------------------------------------------------
function MyAutoVendor:OnInitialize()
    MyAutoVendorDB = MyAutoVendorDB or {}

    MyAutoVendorDB.sellList = MyAutoVendorDB.sellList or {}
    MyAutoVendorDB.keepList = MyAutoVendorDB.keepList or {}

    MyAutoVendorDB.autoSell = (MyAutoVendorDB.autoSell ~= nil) and MyAutoVendorDB.autoSell or true

    MyAutoVendorDB.autoKeepRules = MyAutoVendorDB.autoKeepRules or {
        keepGear = true,
        keepQuest = true,
        keepConsumables = true,
        keepProfessionMats = true,
    }

    MyAutoVendor:SetupOptions()
end

---------------------------------------------------------
-- AUTO KEEP RULE ENGINE
---------------------------------------------------------
function MyAutoVendor:ShouldAutoKeep(itemID)
    local name, _, _, _, _, itemType, itemSubType, _, _, _, _, classID = GetItemInfo(itemID)
    if not name then return false end

    local rules = MyAutoVendorDB.autoKeepRules

    if rules.keepGear and (itemType == "Armor" or itemType == "Weapon") then
        return true
    end

    if rules.keepQuest and classID == 12 then
        return true
    end

    if rules.keepConsumables and itemType == "Consumable" then
        return true
    end

    if rules.keepProfessionMats and itemType == "Trade Goods" then
        return true
    end

    return false
end

---------------------------------------------------------
-- ADD ITEM (Sell-tab overrides auto-keep)
---------------------------------------------------------
function MyAutoVendor:AddItem(itemID)
    if self.activeTab == "sell" then
        MyAutoVendorDB.sellList[itemID] = true
        MyAutoVendor:RefreshUI()
        return
    end

    if MyAutoVendor:ShouldAutoKeep(itemID) then
        MyAutoVendorDB.keepList[itemID] = true
    else
        MyAutoVendorDB.keepList[itemID] = true
    end

    MyAutoVendor:RefreshUI()
end

---------------------------------------------------------
-- REMOVE ITEM
---------------------------------------------------------
function MyAutoVendor:RemoveItem(itemID)
    if self.activeTab == "keep" then
        MyAutoVendorDB.keepList[itemID] = nil
    else
        MyAutoVendorDB.sellList[itemID] = nil
    end

    MyAutoVendor:RefreshUI()
end

---------------------------------------------------------
-- DRAG AND DROP
---------------------------------------------------------
function MyAutoVendor:HandleDrop()
    local type, itemID = GetCursorInfo()
    if type == "item" and itemID then
        ClearCursor()
        MyAutoVendor:AddItem(itemID)
    end
end

---------------------------------------------------------
-- AUTO SELL (AutoVendor logic)
---------------------------------------------------------
function MyAutoVendor:OnEnable()
    self:RegisterEvent("MERCHANT_SHOW")
end

function MyAutoVendor:MERCHANT_SHOW()
    if not MyAutoVendorDB.autoSell then return end

    local soldItems = {}
    local totalCopper = 0
    local iconSize = select(2, GetChatWindowInfo(1)) - 2

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemID = tonumber(string.match(link, "item:(%d+)"))

                -- SELL LIST OVERRIDES AUTO KEEP
                if MyAutoVendorDB.sellList[itemID] then

                    -- AutoVendor vendor price (the ONLY stable method)
                    local vendorPrice = select(11, GetItemInfo(link))
                    vendorPrice = tonumber(vendorPrice) or 0

                    local itemCount = select(2, GetContainerItemInfo(bag, slot)) or 1
                    local sellValue = vendorPrice * itemCount

                    totalCopper = totalCopper + sellValue

                    local name = GetItemInfo(itemID) or ("Item " .. itemID)

                    soldItems[#soldItems + 1] = {
                        name = name,
                        count = itemCount,
                        price = vendorPrice
                    }

                    UseContainerItem(bag, slot)
                else
                    if MyAutoVendor:ShouldAutoKeep(itemID) then
                        MyAutoVendorDB.keepList[itemID] = true
                    end
                end
            end
        end
    end

    -- Chat output
    if #soldItems > 0 then
        local gold = math.floor(totalCopper / 10000)
        local silver = math.floor((totalCopper % 10000) / 100)
        local copper = totalCopper % 100

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00MyAutoVendor: Solgte " .. #soldItems .. " item(s).|r")

        for _, info in ipairs(soldItems) do
            DEFAULT_CHAT_FRAME:AddMessage(
                string.format(" - %s x%d (vendor: %dg %ds %dc)",
                    info.name,
                    info.count,
                    math.floor(info.price / 10000),
                    math.floor((info.price % 10000) / 100),
                    info.price % 100
                )
            )
        end

        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cffffff00Total: %dg %ds %dc|r", gold, silver, copper)
        )
    end
end
