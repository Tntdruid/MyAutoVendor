-- UI.lua – MyAutoVendor (AzerothCore + Ace3)
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function CharKey()
    return (UnitName("player") or "Unknown") .. "-" .. (GetRealmName() or "Realm")
end

local function GetCharDB()
    addon.char = addon.char or {}
    addon._charKey = addon._charKey or CharKey()
    addon.char[addon._charKey] = addon.char[addon._charKey] or {
        keepList = {},
        sellList = {}
    }
    return addon.char[addon._charKey]
end

local function safe(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then print("MyAutoVendor ERROR:", err) end
end

---------------------------------------------------------------------
-- MAIN FRAME
---------------------------------------------------------------------
local function CreateMainFrame()
    if addon.UIFrame then return addon.UIFrame end

    local frame = CreateFrame("Frame", "MyAutoVendorFrame", UIParent)
    frame:SetSize(520, 480)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0, 0, 0, 0.6)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("MyAutoVendor")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)

    ---------------------------------------------------------------------
    -- TABS
    ---------------------------------------------------------------------
    local function MakeTab(x, text)
        local btn = CreateFrame("Button", nil, frame)
        btn:SetSize(110, 24)
        btn:SetPoint("TOPLEFT", x, -40)

        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetTexture(0, 0, 0, 0.2)

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.label:SetPoint("CENTER")
        btn.label:SetText(text)

        function btn:SetActive(active)
            if active then
                btn.bg:SetTexture(0.2, 0.2, 0.2, 0.6)
                btn.label:SetTextColor(1, 0.85, 0)
            else
                btn.bg:SetTexture(0, 0, 0, 0.2)
                btn.label:SetTextColor(1, 1, 1)
            end
        end

        return btn
    end

    local tabKeep = MakeTab(16, "Keep")
    local tabSell = MakeTab(140, "Sell")

    ---------------------------------------------------------------------
    -- SCROLL LIST
    ---------------------------------------------------------------------
    local scroll = CreateFrame("ScrollFrame", "MyAutoVendorScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -72)
    scroll:SetPoint("BOTTOMRIGHT", -40, 200)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)

    local ROWS = {}
    local MAX_ROWS = 14

    for i = 1, MAX_ROWS do
        local row = CreateFrame("Button", nil, content)
        row:SetSize(440, 20)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * 20)

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:SetTexture(0, 0, 0, i % 2 == 0 and 0.18 or 0.12)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 6, 0)

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)

        row:SetScript("OnClick", function(self)
            content.selected = i
            for _, r in ipairs(ROWS) do r.text:SetTextColor(1, 1, 1) end
            self.text:SetTextColor(1, 1, 0)
        end)

        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.itemID then GameTooltip:SetHyperlink("item:" .. self.itemID) end
            GameTooltip:Show()
            self.bg:SetTexture(0.2, 0.2, 0.2, 0.4)
        end)

        row:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            row.bg:SetTexture(0, 0, 0, i % 2 == 0 and 0.18 or 0.12)
        end)

        ROWS[i] = row
    end

    ---------------------------------------------------------------------
    -- DROP ZONE
    ---------------------------------------------------------------------
    local drop = CreateFrame("Button", nil, frame)
    drop:SetSize(440, 64)
    drop:SetPoint("BOTTOMLEFT", 16, 120)

    drop.bg = drop:CreateTexture(nil, "BACKGROUND")
    drop.bg:SetAllPoints()
    drop.bg:SetTexture(0.06, 0.06, 0.06, 0.6)

    drop.label = drop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    drop.label:SetPoint("CENTER")
    drop.label:SetText("Drop items her for at tilføje til Sell-listen")

    drop:SetScript("OnReceiveDrag", function()
        local t, item = GetCursorInfo()
        if t ~= "item" then return end

        local itemID = tonumber(item) or tonumber(item:match("item:(%d+)"))
        if not itemID then return end

        local db = GetCharDB()
        db.sellList[itemID] = { ts = time(), link = "item:" .. itemID }

        addon.activeTab = "sell"
        safe(addon.RefreshUI, addon)

        ClearCursor()
        print("MyAutoVendor: Tilføjet", itemID)
    end)

    ---------------------------------------------------------------------
    -- INPUT + BUTTONS
    ---------------------------------------------------------------------
    local input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    input:SetPoint("BOTTOMLEFT", 16, 16)
    input:SetSize(300, 24)
    input:SetAutoFocus(false)

    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(70, 24)
    clearBtn:SetPoint("BOTTOMRIGHT", -16, 16)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        local db = GetCharDB()
        if addon.activeTab == "sell" then db.sellList = {} else db.keepList = {} end
        safe(addon.RefreshUI, addon)
    end)

    local removeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    removeBtn:SetSize(70, 24)
    removeBtn:SetPoint("RIGHT", clearBtn, "LEFT", -8, 0)
    removeBtn:SetText("Remove")
    removeBtn:SetScript("OnClick", function()
        local sel = content.selected
        if not sel then return end
        local row = ROWS[sel]
        if not row.itemID then return end
        safe(addon.RemoveItem, addon, row.itemID)
    end)

    local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 24)
    addBtn:SetPoint("RIGHT", removeBtn, "LEFT", -8, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local id = tonumber(input:GetText())
        if not id then return end
        safe(addon.AddItem, addon, id)
        input:SetText("")
    end)

    local undoBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    undoBtn:SetSize(70, 24)
    undoBtn:SetPoint("RIGHT", addBtn, "LEFT", -8, 0)
    undoBtn:SetText("Undo")
    undoBtn:SetScript("OnClick", function()
        safe(addon.Undo, addon)
    end)

    local optBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    optBtn:SetSize(90, 24)
    optBtn:SetPoint("RIGHT", undoBtn, "LEFT", -8, 0)
    optBtn:SetText("Options")
    optBtn:SetScript("OnClick", function()
        local ACD = LibStub("AceConfigDialog-3.0", true)
        if ACD then ACD:Open("MyAutoVendor") end
    end)

    ---------------------------------------------------------------------
    -- REFRESH UI
    ---------------------------------------------------------------------
    function addon:RefreshUI()
        local db = GetCharDB()
        local list = addon.activeTab == "sell" and db.sellList or db.keepList

        local ids = {}
        for id,_ in pairs(list) do table.insert(ids, id) end
        table.sort(ids)

        for i,row in ipairs(ROWS) do
            local id = ids[i]
            if id then
                row.itemID = id
                local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)
                row.icon:SetTexture(icon or "")
                row.text:SetText(name or ("item:" .. id))
                row:Show()
            else
                row.itemID = nil
                row.text:SetText("")
                row.icon:SetTexture("")
                row:Hide()
            end
        end

        tabKeep:SetActive(addon.activeTab == "keep")
        tabSell:SetActive(addon.activeTab == "sell")
    end

    ---------------------------------------------------------------------
    -- TAB CLICK HANDLERS
    ---------------------------------------------------------------------
    tabKeep:SetScript("OnClick", function()
        addon.activeTab = "keep"
        safe(addon.RefreshUI, addon)
    end)

    tabSell:SetScript("OnClick", function()
        addon.activeTab = "sell"
        safe(addon.RefreshUI, addon)
    end)

    addon.UIFrame = frame
    return frame
end

---------------------------------------------------------------------
-- TOGGLE UI
---------------------------------------------------------------------
function addon:ToggleUI()
    local f = addon.UIFrame or CreateMainFrame()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        safe(addon.RefreshUI, addon)
    end
end

---------------------------------------------------------------------
-- MERCHANT BUTTON
---------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("MERCHANT_SHOW")
ev:RegisterEvent("MERCHANT_CLOSED")
ev:SetScript("OnEvent", function(_, e)
    if e == "MERCHANT_SHOW" then
        if not MyAutoVendorVendorButton then
            local btn = CreateFrame("Button", "MyAutoVendorVendorButton", MerchantFrame, "UIPanelButtonTemplate")
            btn:SetSize(80, 24)
            btn:SetPoint("TOPRIGHT", -36, -36)
            btn:SetText("MyAV")
            btn:SetScript("OnClick", function() addon:ToggleUI() end)
        end
        MyAutoVendorVendorButton:Show()
    else
        if MyAutoVendorVendorButton then MyAutoVendorVendorButton:Hide() end
    end
end)

---------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------
local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_,_,name)
    if name == ADDON_NAME then
        CreateMainFrame()
        safe(addon.RefreshUI, addon)
    end
end)
