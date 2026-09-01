-- Config.lua – MyAutoVendor (Ace3 options panel)
local ADDON_NAME = ...
local addon = _G[ADDON_NAME]

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

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
            set = function(_, val) addon.profile.autoSell = val end,
        },

        header1 = { type="header", name="Auto-keep regler", order=2 },

        keepConsumables = {
            type = "toggle",
            name = "Behold consumables",
            order = 3,
            get = function() return addon.profile.autoKeepRules.keepConsumables end,
            set = function(_, val) addon.profile.autoKeepRules.keepConsumables = val end,
        },

        keepQuest = {
            type = "toggle",
            name = "Behold quest items",
            order = 4,
            get = function() return addon.profile.autoKeepRules.keepQuest end,
            set = function(_, val) addon.profile.autoKeepRules.keepQuest = val end,
        },

        keepGear = {
            type = "toggle",
            name = "Behold gear",
            order = 5,
            get = function() return addon.profile.autoKeepRules.keepGear end,
            set = function(_, val) addon.profile.autoKeepRules.keepGear = val end,
        },

        keepProfessionMats = {
            type = "toggle",
            name = "Behold profession mats",
            order = 6,
            get = function() return addon.profile.autoKeepRules.keepProfessionMats end,
            set = function(_, val) addon.profile.autoKeepRules.keepProfessionMats = val end,
        },

        header2 = { type="header", name="Minimap ikon", order=10 },

        minimap = {
            type = "toggle",
            name = "Vis minimap ikon",
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

        header3 = { type="header", name="Database", order=20 },

        resetChar = {
            type = "execute",
            name = "Nulstil karakter-lister",
            order = 21,
            func = function()
                addon.char[addon._charKey] = { keepList={}, sellList={} }
                if addon.RefreshUI then addon:RefreshUI() end
                addon:Print("Keep/Sell-lister nulstillet for " .. addon._charKey)
            end,
        },

        resetProfile = {
            type = "execute",
            name = "Nulstil profil",
            order = 22,
            func = function()
                addon.db:ResetProfile()
                addon:Print("Profil nulstillet.")
            end,
        },
    },
}

AceConfig:RegisterOptionsTable("MyAutoVendor", options)
AceConfigDialog:AddToBlizOptions("MyAutoVendor", "MyAutoVendor")
