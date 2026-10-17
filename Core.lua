-- Core.lua – MyAutoVendor (AzerothCore + Ace3)
local ADDON_NAME = ...
local MyAutoVendor = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceConsole-3.0",
    "AceEvent-3.0"
)
_G[ADDON_NAME] = MyAutoVendor

-- Keep the addon usable if an older client does not load the optional locale file.
if not MyAutoVendor.T then
    function MyAutoVendor:T(key)
        return key
    end
end

local AceDB = LibStub("AceDB-3.0")

local defaults = {
    profile = {
        autoSell = true,
        language = "en",
        minimap = {},
        globalSellList = {},   -- ★ GLOBAL SELL LIST
        globalKeepList = {},   -- ★ GLOBAL KEEP LIST
    },
    char = {
        autoKeepRules = {
            keepConsumables = true,
            keepQuest = true,
            keepGear = true,
            keepProfessionMats = true,
            minIlvl = 0,
            maxIlvl = 300,
        },
    }
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

---------------------------------------------------------------------
-- AUTO KEEP FIX (ITEM_INFO_RECEIVED)
---------------------------------------------------------------------
local infoWait = {}
local merchantPending = false

local infoFrame = CreateFrame("Frame")
infoFrame:RegisterEvent("ITEM_INFO_RECEIVED")
infoFrame:SetScript("OnEvent", function(_, _, itemID)
    if infoWait[itemID] then
        infoWait[itemID] = nil
    end
    if merchantPending then
        MyAutoVendor:OnMerchantShow()
    end
end)

local hardcodedKeepNames = {
    ["Legplates of the Lost Protector"] = true,
    ["Crown of the Wayward Protector"] = true,
    ["Mantle of the Lost Protector"] = true,
}

local function IsHardcodedKeepName(name)
    if not name then return false end
    return hardcodedKeepNames[name] == true
end

function MyAutoVendor:EvaluateAutoKeep(itemID)
    local name, _, _, itemLevel, _, itemType, itemSubType, _, equipLoc = GetItemInfo(itemID)
    if not name then return end

    local db = self.char[self._charKey]
    if IsHardcodedKeepName(name) then
        self.profile.globalSellList[itemID] = nil
        db.sellList[itemID] = nil
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID }
        return
    end

    if itemType == "Projectile" or itemType == "Ammo" or itemSubType == "Arrow" or itemSubType == "Bullet" then
        self.profile.globalSellList[itemID] = nil
        db.sellList[itemID] = nil
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID }
        return
    end

    local rules = db.autoKeepRules or defaults.char.autoKeepRules
    local global = self.profile.globalKeepList

    -- An explicit sell rule must not be converted into an auto-keep rule.
    if db.sellList[itemID] or self.profile.globalSellList[itemID] then
        return
    end

    -- Already kept globally
    if global[itemID] then return end

    -- Already kept locally
    if db.keepList[itemID] then return end

    -- Consumables
    if rules.keepConsumables and itemType == "Consumable" then
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID }
        return
    end

    -- Quest items
    if rules.keepQuest and itemType == "Quest" then
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID }
        return
    end

    -- Gear
    local minIlvl = tonumber(rules.minIlvl) or 0
    local maxIlvl = tonumber(rules.maxIlvl) or math.huge
    local hasItemLevel = type(itemLevel) == "number" and itemLevel > 0
    local gearInRange = hasItemLevel and (itemLevel >= minIlvl and itemLevel <= maxIlvl)

    if rules.keepGear and hasItemLevel and equipLoc and equipLoc ~= "" and gearInRange then
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID, auto = true }
        return
    end

    -- Profession mats
    if rules.keepProfessionMats and itemType == "Trade Goods" then
        db.keepList[itemID] = { ts = time(), link = "item:"..itemID }
        return
    end
end

---------------------------------------------------------------------
-- PRUNE KEEP LIST (dynamic re-evaluation against current rules)
---------------------------------------------------------------------
-- Removes auto-added keep entries (never manually pinned) that no longer
-- satisfy the current auto-keep rules, e.g. gear that fell below/above the
-- ilvl range, or consumables/gear/profession mats whose rule got disabled.
-- Also removes any keep entry whose item is on the local or global sell list.
function MyAutoVendor:PruneKeepList()
    local db = self.char[self._charKey]
    local rules = db.autoKeepRules or defaults.char.autoKeepRules
    local minIlvl = tonumber(rules.minIlvl) or 0
    local maxIlvl = tonumber(rules.maxIlvl) or math.huge

    local globalSell = self.profile.globalSellList

    local changed = false
    for id, entry in pairs(db.keepList) do
        -- Sell overrides local Keep, so an item on a sell list is dropped from Keep.
        if db.sellList[id] or globalSell[id] then
            db.keepList[id] = nil
            changed = true
        elseif not entry.manual then
            local name, _, _, itemLevel, _, itemType, itemSubType, _, equipLoc = GetItemInfo(id)
            if name then
                local hardcodedKeep = IsHardcodedKeepName(name)
                local ammoKeep = itemType == "Projectile" or itemType == "Ammo"
                    or itemSubType == "Arrow" or itemSubType == "Bullet"

                if not hardcodedKeep and not ammoKeep then
                    local isGear = equipLoc and equipLoc ~= ""
                    local hasItemLevel = type(itemLevel) == "number" and itemLevel > 0
                    local keepThis

                    if isGear then
                        keepThis = rules.keepGear and hasItemLevel
                            and itemLevel >= minIlvl and itemLevel <= maxIlvl
                    elseif itemType == "Consumable" then
                        keepThis = rules.keepConsumables
                    elseif itemType == "Quest" then
                        keepThis = rules.keepQuest
                    elseif itemType == "Trade Goods" then
                        keepThis = rules.keepProfessionMats
                    else
                        keepThis = true
                    end

                    if not keepThis then
                        db.keepList[id] = nil
                        changed = true
                    end
                end
            end
        end
    end

    if changed and self.RefreshUI then
        self:RefreshUI()
    end
end

---------------------------------------------------------------------
-- SHARED PROFILE
---------------------------------------------------------------------
-- Older saved variables gave every character its own AceDB profile, which
-- made the "global" lists per character. Fold those lists into the shared
-- Default profile once, then keep every character on Default.
function MyAutoVendor:UseSharedProfile()
    local db = self.db
    local current = db:GetCurrentProfile()

    if not db.global.profilesMerged and db.profiles then
        db.profiles["Default"] = db.profiles["Default"] or {}
        local target = db.profiles["Default"]

        for name, profile in pairs(db.profiles) do
            if name ~= "Default" then
                for _, key in ipairs({ "globalSellList", "globalKeepList" }) do
                    if type(profile[key]) == "table" then
                        target[key] = target[key] or {}
                        for id, meta in pairs(profile[key]) do
                            if target[key][id] == nil then
                                target[key][id] = meta
                            end
                        end
                    end
                end
            end
        end

        local currentProfile = db.profiles[current]
        if target.language == nil and currentProfile and currentProfile.language then
            target.language = currentProfile.language
        end

        db.global.profilesMerged = true
    end

    if current ~= "Default" then
        db:SetProfile("Default")
    end
end

---------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------
function MyAutoVendor:OnInitialize()
    self.db = AceDB:New("MyAutoVendorDB", defaults, true)
    self:UseSharedProfile()
    self.profile = self.db.profile
    self.char = self.db.char
    self._charKey = CharKey()

    self.char[self._charKey] = self.char[self._charKey] or {}
    self.char[self._charKey].keepList = self.char[self._charKey].keepList or {}
    self.char[self._charKey].sellList = self.char[self._charKey].sellList or {}
    self.char[self._charKey].autoKeepRules = self.char[self._charKey].autoKeepRules or {}
    for k, v in pairs(defaults.char.autoKeepRules) do
        if self.char[self._charKey].autoKeepRules[k] == nil then
            self.char[self._charKey].autoKeepRules[k] = v
        end
    end

    self._undoStack = {}
    self.activeTab = "keep"

    self:RegisterChatCommand("mav", "HandleSlash")
    self:SetupMinimap()
end

function MyAutoVendor:OnEnable()
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:PruneKeepList()
end

---------------------------------------------------------------------
-- MINIMAP ICON
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
            tt:AddLine(MyAutoVendor:T("clickOpen"), 1,1,1)
        end,
    })

    LDBIcon:Register("MyAutoVendor", obj, self.db.profile.minimap)
end

---------------------------------------------------------------------
-- AUTO SELL (local + global) — UDEN GOTO
---------------------------------------------------------------------
function MyAutoVendor:OnMerchantShow()
    if not self.profile.autoSell then return end

    self:PruneKeepList()

    local db = self.char[self._charKey]
    local globalSell = self.profile.globalSellList
    local globalKeep = self.profile.globalKeepList

    local soldItems = {}
    local total = 0
    merchantPending = false

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do

            local link = GetContainerItemLink(bag, slot)
            if link then
                local id = tonumber(link:match("item:(%d+)"))
                if id then

                    -- Ensure item info is loaded
                    local name, _, _, itemLevel, _, itemType, itemSubType, _, equipLoc = GetItemInfo(id)
                    if not name then
                        infoWait[id] = true
                        merchantPending = true
                    else
                        self:EvaluateAutoKeep(id)
                    end

                    if name then
                        local hardcodedKeep = IsHardcodedKeepName(name)
                        local ammoKeep = itemType == "Projectile" or itemType == "Ammo" or itemSubType == "Arrow" or itemSubType == "Bullet"
                        if hardcodedKeep or ammoKeep then
                            db.keepList[id] = db.keepList[id] or { ts = time(), link = "item:"..id }
                            db.sellList[id] = nil
                            globalSell[id] = nil
                        end

                        local rules = db.autoKeepRules or defaults.char.autoKeepRules
                        local minIlvl = tonumber(rules.minIlvl) or 0
                        local autoKeepEntry = db.keepList[id]

                        -- Global Keep overrides Sell; Sell overrides local/automatic Keep.
                        local explicitSell = db.sellList[id] or (globalSell[id] and not (hardcodedKeep or ammoKeep))
                        local keep = globalKeep[id] or autoKeepEntry or hardcodedKeep or ammoKeep
                        local protectedItem = itemType == "Container"
                            or itemType == "Projectile"
                            or itemType == "Ammo"
                            or itemSubType == "Tools"
                            or itemSubType == "Miscellaneous"
                            or itemSubType == "Arrow"
                            or itemSubType == "Bullet"
                        local vendorPrice = select(11, GetItemInfo(id)) or 0
                        local autoSellLowGear = not protectedItem
                            and equipLoc and equipLoc ~= ""
                            and itemLevel and itemLevel < minIlvl
                            and vendorPrice > 0
                        local shouldSell = explicitSell or (autoSellLowGear and not keep)

                        if shouldSell and not globalKeep[id] then
                            -- SELL (local, global, or below the automatic gear threshold)
                            local itemName = name
                            local price = vendorPrice
                            local _, count = GetContainerItemInfo(bag, slot)
                            count = count or 1

                            local value = price * count
                            total = total + value

                            table.insert(soldItems, {
                                id=id, name=itemName, count=count, price=price, value=value
                            })

                            UseContainerItem(bag, slot)
                        end
                    end
                end
            end

        end
    end

    if merchantPending then
        return
    end

    if #soldItems > 0 then
        print("|cff00ff00" .. self:T("sold"):format(#soldItems) .. "|r")
        for _, info in ipairs(soldItems) do
            print(string.format(" - %s x%d", info.name, info.count))
        end
        print("|cffffff00" .. self:T("totalSold") .. FormatCopper(total) .. "|r")
    end
end

---------------------------------------------------------------------
-- ADD / REMOVE / UNDO (local/global)
---------------------------------------------------------------------
function MyAutoVendor:AddItem(input)
    local id = toItemId(input)
    if not id then return print(self:T("invalidItem")) end

    local name = GetItemInfo(id) or ("item:"..id)

    local listName =
        self.activeTab == "sell"       and "sellList" or
        self.activeTab == "globalSell" and "globalSellList" or
        self.activeTab == "globalKeep" and "globalKeepList" or
        "keepList"

    local list =
        listName == "globalSellList" and self.profile.globalSellList or
        listName == "globalKeepList" and self.profile.globalKeepList or
        self.char[self._charKey][listName]

    list[id] = { ts = time(), link = "item:"..id, manual = listName == "keepList" }

    if listName == "sellList" or listName == "globalSellList" then
        self:PruneKeepList()
    end

    print(self:T("added") .. name)
    if self.RefreshUI then self:RefreshUI() end
end

function MyAutoVendor:RemoveItem(input)
    local id = toItemId(input)
    if not id then return end

    local listName =
        self.activeTab == "sell"       and "sellList" or
        self.activeTab == "globalSell" and "globalSellList" or
        self.activeTab == "globalKeep" and "globalKeepList" or
        "keepList"

    local list =
        listName == "globalSellList" and self.profile.globalSellList or
        listName == "globalKeepList" and self.profile.globalKeepList or
        self.char[self._charKey][listName]

    if list[id] then
        table.insert(self._undoStack, { id=id, meta=list[id], tab=self.activeTab })
        list[id] = nil
        print(self:T("removed"):format(id))
        if self.RefreshUI then self:RefreshUI() end
    end
end

function MyAutoVendor:Undo()
    local u = table.remove(self._undoStack)
    if not u then return print(self:T("nothingUndo")) end

    local listName =
        u.tab == "sell"       and "sellList" or
        u.tab == "globalSell" and "globalSellList" or
        u.tab == "globalKeep" and "globalKeepList" or
        "keepList"

    local list =
        listName == "globalSellList" and self.profile.globalSellList or
        listName == "globalKeepList" and self.profile.globalKeepList or
        self.char[self._charKey][listName]

    list[u.id] = u.meta

    print(self:T("undone"):format(u.id))
    if self.RefreshUI then self:RefreshUI() end
end

---------------------------------------------------------------------
-- SLASH
---------------------------------------------------------------------
function MyAutoVendor:HandleSlash(msg)
    if msg == "ui" then return self:ToggleUI() end
    if msg == "undo" then return self:Undo() end
    local language = msg:match("^lang%s+(%S+)$")
    if language and self.Languages[language] then
        self.profile.language = language
        print(self:T("languageSet"):format(self:T("languageName")))
        return ReloadUI()
    end
    print(self:T("slashUi"))
    print(self:T("slashUndo"))
    print(self:T("slashLang"))
end
