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
