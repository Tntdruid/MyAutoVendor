local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function MyAutoVendor:SetupOptions()
    local options = {
        type = "group",
        args = {
            autoSell = {
                type = "toggle",
                name = "Auto-sell at vendor",
                desc = "Automatically sell items on the Sell List",
                get = function() return MyAutoVendorDB.autoSell end,
                set = function(_, val) MyAutoVendorDB.autoSell = val end,
            },

            autoKeepRules = {
                type = "group",
                name = "Auto-Keep Rules",
                args = {
                    keepGear = {
                        type = "toggle",
                        name = "Keep all gear",
                        desc = "Protect armor and weapons",
                        get = function() return MyAutoVendorDB.autoKeepRules.keepGear end,
                        set = function(_, val) MyAutoVendorDB.autoKeepRules.keepGear = val end,
                    },
                    keepQuest = {
                        type = "toggle",
                        name = "Keep quest items",
                        desc = "Protect quest items",
                        get = function() return MyAutoVendorDB.autoKeepRules.keepQuest end,
                        set = function(_, val) MyAutoVendorDB.autoKeepRules.keepQuest = val end,
                    },
                    keepConsumables = {
                        type = "toggle",
                        name = "Keep consumables",
                        desc = "Protect potions, food, bandages, etc.",
                        get = function() return MyAutoVendorDB.autoKeepRules.keepConsumables end,
                        set = function(_, val) MyAutoVendorDB.autoKeepRules.keepConsumables = val end,
                    },
                    keepProfessionMats = {
                        type = "toggle",
                        name = "Keep profession materials",
                        desc = "Protect cloth, leather, ore, herbs, etc.",
                        get = function() return MyAutoVendorDB.autoKeepRules.keepProfessionMats end,
                        set = function(_, val) MyAutoVendorDB.autoKeepRules.keepProfessionMats = val end,
                    },
                },
            },

            openUI = {
                type = "execute",
                name = "Open UI",
                func = function() MyAutoVendor:OpenUI() end,
            },
        },
    }

    AceConfig:RegisterOptionsTable("MyAutoVendor", options)
    AceConfigDialog:AddToBlizOptions("MyAutoVendor", "MyAutoVendor")

    SLASH_MYAUTOVENDOR1 = "/mav"
    SlashCmdList["MYAUTOVENDOR"] = function()
        MyAutoVendor:OpenUI()
    end
end
