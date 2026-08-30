local ADDON_NAME = ...
local MAV = MyAutoVendor

---------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------
local frame = nil

function MAV:OpenUI()
    if frame and frame:IsShown() then
        frame:Hide()
        return
    end

    frame = CreateFrame("Frame", "MyAutoVendorUI", UIParent)
    frame:SetSize(400, 450)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -----------------------------------------------------
    -- TITLE
    -----------------------------------------------------
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("MyAutoVendor")

    -----------------------------------------------------
    -- TAB BUTTONS
    -----------------------------------------------------
    local keepTab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    keepTab:SetSize(80, 25)
    keepTab:SetPoint("TOPLEFT", 20, -40)
    keepTab:SetText("Keep")
    keepTab:SetScript("OnClick", function()
        MAV.activeTab = "keep"
        MAV:RefreshUI()
    end)

    local sellTab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    sellTab:SetSize(80, 25)
    sellTab:SetPoint("TOPLEFT", 110, -40)
    sellTab:SetText("Sell")
    sellTab:SetScript("OnClick", function()
        MAV.activeTab = "sell"
        MAV:RefreshUI()
    end)

    -----------------------------------------------------
    -- DRAG & DROP ZONE
    -----------------------------------------------------
    local dropZone = CreateFrame("Frame", nil, frame)
    dropZone:SetSize(360, 40)
    dropZone:SetPoint("TOP", 0, -90)
    dropZone:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    dropZone:SetBackdropColor(0, 0, 0, 0.4)

    local dzText = dropZone:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dzText:SetPoint("CENTER")
    dzText:SetText("Drop item here to add")

    dropZone:SetScript("OnMouseUp", function()
        MAV:HandleDrop()
    end)

    -----------------------------------------------------
    -- SCROLL FRAME
    -----------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", "MyAutoVendorScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -140)
    scrollFrame:SetSize(360, 260)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(360, 260)
    scrollFrame:SetScrollChild(content)

    MAV.activeScroll = content

    -----------------------------------------------------
    -- CLOSE BUTTON
    -----------------------------------------------------
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 25)
    closeBtn:SetPoint("BOTTOM", 0, 20)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    MAV.activeTab = MAV.activeTab or "keep"
    MAV:RefreshUI()
end

---------------------------------------------------------
-- REFRESH UI
---------------------------------------------------------
function MAV:RefreshUI()
    if not frame or not MAV.activeScroll then return end

    local list = (MAV.activeTab == "keep") and MyAutoVendorDB.keepList or MyAutoVendorDB.sellList

    local content = MAV.activeScroll
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local y = -10

    for itemID, _ in pairs(list) do
        local name, link = GetItemInfo(itemID)
        link = link or ("Item " .. itemID)

        local row = CreateFrame("Frame", nil, content)
        row:SetSize(340, 20)
        row:SetPoint("TOPLEFT", 10, y)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT")
        text:SetText(link)

        local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        removeBtn:SetSize(60, 20)
        removeBtn:SetPoint("RIGHT")
        removeBtn:SetText("Remove")
        removeBtn:SetScript("OnClick", function()
            MAV:RemoveItem(itemID)
        end)

        y = y - 25
    end

    content:SetHeight(math.abs(y))
end
