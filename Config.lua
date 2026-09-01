-- Config.lua – MyAutoVendor (Ace3 options panel)
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

---------------------------------------------------------------------
-- Options table
---------------------------------------------------------------------
local options = {
    type = "group",
    name = "MyAutoVendor",
    args = {

        autosell = {
            type = "toggle",
            name = "Auto-sell aktiveret",
            desc = "Sælg automatisk items i din Sell-liste når du åbner en merchant.",
            order = 1,
            get = function() return addon.profile.autoSell end,
            set = function(_, val)
                addon.profile.autoSell = val
            end,
        },

        header1 = {
            type = "header",
            name = "Auto-keep regler",
            order = 2,
        },

        keepConsumables = {
            type = "toggle",
            name = "Behold consumables",
            desc = "Behold potions, bandages, mad osv.",
            order = 3,
            get = function() return addon.profile.autoKeepRules.keepConsumables end,
            set = function(_, val)
                addon.profile.autoKeepRules.keepConsumables = val
            end,
        },

        keepQuest = {
            type = "toggle",
            name = "Behold quest items",
            desc = "Behold alle quest items automatisk.",
            order = 4,
            get = function() return addon.profile.autoKeepRules.keepQuest end,
            set = function(_, val)
                addon.profile.autoKeepRules.keepQuest = val
            end,
        },

        keepGear = {
            type = "toggle",
            name = "Behold gear",
            desc = "Behold alle våben og armor automatisk.",
            order = 5,
            get = function() return addon.profile.autoKeepRules.keepGear end,
            set = function(_, val)
                addon.profile.autoKeepRules.keepGear = val
            end,
        },

        keepProfessionMats = {
            type = "toggle",
            name = "Behold profession mats",
            desc = "Behold alle profession materialer automatisk.",
            order = 6,
            get = function() return addon.profile.autoKeepRules.keepProfessionMats end,
            set = function(_, val)
                addon.profile.autoKeepRules.keepProfessionMats = val
            end,
        },

        header2 = {
            type = "header",
            name = "Minimap ikon",
            order = 10,
        },

        minimap = {
            type = "toggle",
            name = "Vis minimap ikon",
            desc = "Slå MyAutoVendor minimap-ikonet til/fra.",
            order = 11,
            get = function() return not addon.db.profile.minimap.hide end,
            set = function(_, val)
                addon.db.profile.minimap.hide = not val
                local LDBIcon = LibStub("LibDBIcon-1.0", true)
                if LDBIcon then
                    if val then LDBIcon:Show("MyAutoVendor") else LDBIcon:Hide("MyAutoVendor") end
                end
            end,
        },

        header3 = {
            type = "header",
            name = "Database",
            order = 20,
        },

        resetChar = {
            type = "execute",
            name = "Nulstil karakter-lister",
            desc = "Slet keep/sell-lister for denne karakter.",
            order = 21,
            func = function()
                addon.char[addon._charKey] = { keepList = {}, sellList = {} }
                if addon.RefreshUI then addon:RefreshUI() end
                addon:Print("Keep/Sell-lister nulstillet for " .. addon._charKey)
            end,
        },

        resetProfile = {
            type = "execute",
            name = "Nulstil profil",
            desc = "Nulstil alle profil-indstillinger.",
            order = 22,
            func = function()
                addon.db:ResetProfile()
                addon:Print("Profil nulstillet.")
            end,
        },
    },
}

---------------------------------------------------------------------
-- Register options
---------------------------------------------------------------------
AceConfig:RegisterOptionsTable("MyAutoVendor", options)
AceConfigDialog:AddToBlizOptions("MyAutoVendor", "MyAutoVendor")
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
