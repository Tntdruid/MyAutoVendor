local AceGUI = LibStub("AceGUI-3.0")

local uiFrame

---------------------------------------------------------
-- ITEM ROW
---------------------------------------------------------
local function CreateItemRow(itemID)
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout("Flow")
    row:SetFullWidth(true)
    row:SetHeight(40)

    local f = row.frame
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.4)

    local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)

    ---------------------------------------------------------
    -- ICON
    ---------------------------------------------------------
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 5, 0)
    icon:SetTexture(texture or "Interface/Icons/INV_Misc_QuestionMark")

    ---------------------------------------------------------
    -- NAME
    ---------------------------------------------------------
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    local color = ITEM_QUALITY_COLORS[quality or 1].hex
    label:SetText(color .. (name or ("Item " .. itemID)) .. "|r")

    ---------------------------------------------------------
    -- REMOVE BUTTON
    ---------------------------------------------------------
    local removeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    removeBtn:SetText("Remove")
    removeBtn:SetSize(80, 22)
    removeBtn:SetPoint("RIGHT", -10, 0)
    removeBtn:SetScript("OnClick", function()
        MyAutoVendor:RemoveItem(itemID)
    end)

    ---------------------------------------------------------
    -- TOOLTIP
    ---------------------------------------------------------
    f:SetScript("OnEnter", function()
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. itemID)
        GameTooltip:Show()
    end)

    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return row
end

---------------------------------------------------------
-- REFRESH UI
---------------------------------------------------------
function MyAutoVendor:RefreshUI()
    local scroll = self.activeScroll
    if not scroll then return end

    scroll:ReleaseChildren()

    local list = (self.activeTab == "keep") and MyAutoVendorDB.keepList or MyAutoVendorDB.sellList

    for itemID in pairs(list) do
        scroll:AddChild(CreateItemRow(itemID))
    end
end

---------------------------------------------------------
-- MAIN UI
---------------------------------------------------------
function MyAutoVendor:OpenUI()
    if uiFrame then
        uiFrame:Show()
        return
    end

    uiFrame = AceGUI:Create("Frame")
    uiFrame:SetTitle("MyAutoVendor")
    uiFrame:SetStatusText("Sell / Keep Lists")
    uiFrame:SetLayout("Flow")
    uiFrame:SetWidth(450)
    uiFrame:SetHeight(550)

    ---------------------------------------------------------
    -- DROP ZONE
    ---------------------------------------------------------
    local drop = AceGUI:Create("SimpleGroup")
    drop:SetFullWidth(true)
    drop:SetHeight(80)
    drop:SetLayout("Fill")

    local df = drop.frame
    df:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    df:SetBackdropColor(0, 0, 0, 0.7)

    df:EnableMouse(true)
    df:RegisterForDrag("LeftButton")

    local text = df:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER")
    text:SetText("Drag an item here")

    df:SetScript("OnReceiveDrag", function()
        MyAutoVendor:HandleDrop()
    end)

    df:SetScript("OnMouseUp", function()
        MyAutoVendor:HandleDrop()
    end)

    uiFrame:AddChild(drop)

    ---------------------------------------------------------
    -- TABS
    ---------------------------------------------------------
    local tabs = {
        { text = "Sell List", value = "sell" },
        { text = "Keep List", value = "keep" },
    }

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetTabs(tabs)
    tabGroup:SetFullWidth(true)
    tabGroup:SetHeight(400)
    tabGroup:SetLayout("Flow")
    tabGroup:SelectTab("sell")

    uiFrame:AddChild(tabGroup)

    MyAutoVendor.tabGroup = tabGroup

    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()

        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("Flow")
        scroll:SetFullWidth(true)
        scroll:SetHeight(350)

        container:AddChild(scroll)

        MyAutoVendor.activeTab = group
        MyAutoVendor.activeScroll = scroll

        MyAutoVendor:RefreshUI()
    end)

    -- Init first tab
    MyAutoVendor.activeTab = "sell"
    local initialScroll = AceGUI:Create("ScrollFrame")
    initialScroll:SetLayout("Flow")
    initialScroll:SetFullWidth(true)
    initialScroll:SetHeight(350)
    tabGroup:AddChild(initialScroll)
    MyAutoVendor.activeScroll = initialScroll
    MyAutoVendor:RefreshUI()
end
