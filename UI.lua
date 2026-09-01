-- UI.lua – MyAutoVendor – Clean Dark Panel + Right-click Remove + Global Tabs + Tooltips
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local function CharDB()
    return addon.char[addon._charKey]
end

local function GlobalSellDB()
    return addon.profile.globalSellList
end

local function GlobalKeepDB()
    return addon.profile.globalKeepList
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

    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    bg:SetVertexColor(0.07, 0.07, 0.07, 0.95)

    -- Header
    local header = frame:CreateTexture(nil, "ARTWORK")
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetHeight(32)
    header:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -6)
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
        btn.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        btn.bg:SetVertexColor(0.15, 0.15, 0.15, 0.7)

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.label:SetPoint("CENTER")
        btn.label:SetText(text)

        function btn:SetActive(active)
            if active then
                btn.bg:SetVertexColor(1, 0.85, 0, 0.8)
                btn.label:SetTextColor(1, 0.85, 0)
            else
                btn.bg:SetVertexColor(0.15, 0.15, 0.15, 0.7)
                btn.label:SetTextColor(1, 1, 1)
            end
        end

        return btn
    end

    local tabKeep       = MakeTab(16,  "Keep")
    local tabSell       = MakeTab(140, "Sell")
    local tabGlobalKeep = MakeTab(264, "Global Keep")
    local tabGlobalSell = MakeTab(388, "Global Sell")

    ---------------------------------------------------------------------
    -- TOOLTIP SETUP (fra TabTooltips.lua)
    ---------------------------------------------------------------------
    if addon.SetupTabTooltips then
        addon:SetupTabTooltips(tabKeep, tabSell, tabGlobalKeep, tabGlobalSell)
    end

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
        row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        row.bg:SetVertexColor(0, 0, 0, i % 2 == 0 and 0.22 or 0.18)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 6, 0)

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)

        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        row:SetScript("OnClick", function(self, button)
            if button == "RightButton" then
                if self.itemID then addon:RemoveItem(self.itemID) end
                return
            end

            content.selected = i
            for _, r in ipairs(ROWS) do r.text:SetTextColor(1, 1, 1) end
            self.text:SetTextColor(1, 1, 0)
        end)

        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.itemID then GameTooltip:SetHyperlink("item:" .. self.itemID) end
            GameTooltip:Show()
            self.bg:SetVertexColor(0.25, 0.25, 0.25, 0.5)
        end)

        row:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            row.bg:SetVertexColor(0, 0, 0, i % 2 == 0 and 0.22 or 0.18)
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
    drop.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    drop.bg:SetVertexColor(0.12, 0.12, 0.12, 0.8)

    drop.label = drop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    drop.label:SetPoint("CENTER")
    drop.label:SetText("Drop items her for at tilføje til listen")

    drop:SetScript("OnReceiveDrag", function()
        local t, item = GetCursorInfo()
        if t ~= "item" then return end

        local itemID = tonumber(item) or tonumber(item:match("item:(%d+)"))
        if not itemID then return end

        if addon.activeTab == "globalSell" then
            GlobalSellDB()[itemID] = { ts = time(), link = "item:"..itemID }
        elseif addon.activeTab == "globalKeep" then
            GlobalKeepDB()[itemID] = { ts = time(), link = "item:"..itemID }
        elseif addon.activeTab == "sell" then
            CharDB().sellList[itemID] = { ts = time(), link = "item:"..itemID }
        else
            CharDB().keepList[itemID] = { ts = time(), link = "item:"..itemID }
        end

        addon:RefreshUI()
        ClearCursor()
    end)

    ---------------------------------------------------------------------
    -- BUTTONS (Undo / Clear / Options)
    ---------------------------------------------------------------------
    local function SkinButton(btn)
        btn:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
        btn:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
        btn:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")

        btn:GetNormalTexture():SetVertexColor(0.12, 0.12, 0.12, 0.9)
        btn:GetPushedTexture():SetVertexColor(0.18, 0.18, 0.18, 1)
        btn:GetHighlightTexture():SetVertexColor(0.25, 0.25, 0.25, 0.9)

        btn.text = btn:GetFontString()
        btn.text:SetTextColor(1, 0.85, 0)
    end

    local optBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    optBtn:SetSize(90, 24)
    optBtn:SetPoint("BOTTOMRIGHT", -16, 16)
    optBtn:SetText("Options")
    SkinButton(optBtn)
    optBtn:SetScript("OnClick", function()
        local ACD = LibStub("AceConfigDialog-3.0", true)
        if ACD then ACD:Open("MyAutoVendor") end
    end)

    local undoBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    undoBtn:SetSize(70, 24)
    undoBtn:SetPoint("RIGHT", optBtn, "LEFT", -8, 0)
    undoBtn:SetText("Undo")
    SkinButton(undoBtn)
    undoBtn:SetScript("OnClick", function()
        addon:Undo()
    end)

    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(70, 24)
    clearBtn:SetPoint("RIGHT", undoBtn, "LEFT", -8, 0)
    clearBtn:SetText("Clear")
    SkinButton(clearBtn)
    clearBtn:SetScript("OnClick", function()
        if addon.activeTab == "globalSell" then
            addon.profile.globalSellList = {}
        elseif addon.activeTab == "globalKeep" then
            addon.profile.globalKeepList = {}
        elseif addon.activeTab == "sell" then
            CharDB().sellList = {}
        else
            CharDB().keepList = {}
        end
        addon:RefreshUI()
    end)

    ---------------------------------------------------------------------
    -- REFRESH UI
    ---------------------------------------------------------------------
    function addon:RefreshUI()
        local db = CharDB()
        local globalSell = GlobalSellDB()
        local globalKeep = GlobalKeepDB()

        local list =
            self.activeTab == "keep"       and db.keepList or
            self.activeTab == "sell"       and db.sellList or
            self.activeTab == "globalKeep" and globalKeep or
            self.activeTab == "globalSell" and globalSell

        if type(list) ~= "table" then
            list = {}
        end

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

        tabKeep:SetActive(self.activeTab == "keep")
        tabSell:SetActive(self.activeTab == "sell")
        tabGlobalKeep:SetActive(self.activeTab == "globalKeep")
        tabGlobalSell:SetActive(self.activeTab == "globalSell")
    end

    ---------------------------------------------------------------------
    -- TAB CLICK HANDLERS
    ---------------------------------------------------------------------
    tabKeep:SetScript("OnClick", function()
        addon.activeTab = "keep"
        addon:RefreshUI()
    end)

    tabSell:SetScript("OnClick", function()
        addon.activeTab = "sell"
        addon:RefreshUI()
    end)

    tabGlobalKeep:SetScript("OnClick", function()
        addon.activeTab = "globalKeep"
        addon:RefreshUI()
    end)

    tabGlobalSell:SetScript("OnClick", function()
        addon.activeTab = "globalSell"
        addon:RefreshUI()
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
        addon:RefreshUI()
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
        addon:RefreshUI()
    end
end)
