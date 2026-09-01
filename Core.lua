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
        autoSell = true,
        autoKeepRules = {
            keepConsumables = true,
            keepQuest = true,
            keepGear = true,
            keepProfessionMats = true,
        },
        minimap = {},
    },
    char = {}
}

local function CharKey()
    return (UnitName("player") or "Unknown") .. "-" .. (GetRealmName() or "Realm")
end

local function toItemId(input)
    if not input then return nil end
    local n = tonumber(input)
    if n then return n end
    return tonumber(tostring(input):match("item:(%d+)"))
end

local function FormatCopper(c)
    c = tonumber(c) or 0
    local g = math.floor(c / 10000)
    local s = math.floor((c % 10000) / 100)
    local cc = c % 100
    return string.format("%dg %ds %dc", g, s, cc)
end

local function SaveMeta(addon, listName, id)
    local name, link, _,_,icon = GetItemInfo(id)
    addon.char[addon._charKey][listName][id] = {
        ts = time(),
        link = link or ("item:"..id),
        icon = icon,
        name = name or ("item:"..id)
    }
end

function MyAutoVendor:OnInitialize()
    self.db = AceDB:New("MyAutoVendorDB", defaults, true)
    self.profile = self.db.profile
    self.char = self.db.char
    self._charKey = CharKey()

    self.char[self._charKey] = self.char[self._charKey] or {
        keepList = {},
        sellList = {}
    }

    self._undoStack = {}
    self.activeTab = "keep"

    self:RegisterChatCommand("mav", "HandleSlash")
    self:SetupMinimap()
end

function MyAutoVendor:OnEnable()
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
end

---------------------------------------------------------------------
-- Minimap ikon (WotLK kræver type="launcher")
---------------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

function MyAutoVendor:SetupMinimap()
    if not LDB or not LDBIcon then return end

    local obj = LDB:NewDataObject("MyAutoVendor", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Bag_08",
        OnClick = function() MyAutoVendor:ToggleUI() end,
        OnTooltipShow = function(tt)
            tt:AddLine("MyAutoVendor")
            tt:AddLine("Klik for at åbne addon", 1,1,1)
        end,
    })

    LDBIcon:Register("MyAutoVendor", obj, self.db.profile.minimap)
end

---------------------------------------------------------------------
-- AutoSell (clean output)
---------------------------------------------------------------------
function MyAutoVendor:OnMerchantShow()
    if not self.profile.autoSell then return end

    local db = self.char[self._charKey]
    local soldItems = {}
    local total = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local id = tonumber(link:match("item:(%d+)"))
                if id and db.sellList[id] then
                    local name = GetItemInfo(id) or ("item:"..id)
                    local price = select(11, GetItemInfo(id)) or 0
                    local _, count = GetContainerItemInfo(bag, slot)
                    count = count or 1

                    local value = price * count
                    total = total + value

                    table.insert(soldItems, {
                        id=id, name=name, count=count, price=price, value=value
                    })

                    UseContainerItem(bag, slot)
                end
            end
        end
    end

    if #soldItems > 0 then
        print("|cff00ff00Solgte " .. #soldItems .. " item(s):|r")
        for _, info in ipairs(soldItems) do
            print(string.format(
                " - %s x%d (vendor: %s; samlet: %s)",
                info.name,
                info.count,
                FormatCopper(info.price),
                FormatCopper(info.value)
            ))
        end
        print("|cffffff00Total: " .. FormatCopper(total) .. "|r")
    end
end

---------------------------------------------------------------------
-- Add / Remove / Undo (clean output)
---------------------------------------------------------------------
function MyAutoVendor:AddItem(input)
    local id = toItemId(input)
    if not id then return print("Ugyldigt item") end

    local name = GetItemInfo(id) or ("item:"..id)
    local listName = self.activeTab == "sell" and "sellList" or "keepList"

    SaveMeta(self, listName, id)

    print("Tilføjet: " .. name)

    if self.RefreshUI then self:RefreshUI() end
end

function MyAutoVendor:RemoveItem(input)
    local id = toItemId(input)
    if not id then return end

    local listName = self.activeTab == "sell" and "sellList" or "keepList"
    local list = self.char[self._charKey][listName]

    if list[id] then
        table.insert(self._undoStack, { id=id, meta=list[id], tab=self.activeTab })
        list[id] = nil
        print("Fjernet " .. id .. " (kan fortrydes)")
        if self.RefreshUI then self:RefreshUI() end
    end
end

function MyAutoVendor:Undo()
    local u = table.remove(self._undoStack)
    if not u then return print("Intet at fortryde") end

    local listName = u.tab == "sell" and "sellList" or "keepList"
    self.char[self._charKey][listName][u.id] = u.meta

    print("Fortrudt fjernelse af " .. u.id)
    if self.RefreshUI then self:RefreshUI() end
end

---------------------------------------------------------------------
-- Slash
---------------------------------------------------------------------
function MyAutoVendor:HandleSlash(msg)
    if msg == "ui" then return self:ToggleUI() end
    if msg == "undo" then return self:Undo() end
    print("/mav ui  - åbner UI")
    print("/mav undo - fortryd sidste fjernelse")
end
