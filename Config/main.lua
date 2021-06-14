local _, addon = ...
local E = addon.Engine
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

addon.Config = {
    name = addon,
    type = "group",
    args = {
        showAllUnits = {
            name = "Show all units",
            order = 0,
            hidden = true,
            type = "toggle",
            set = function (_, value)
                E.db.profile.showAllUnits = value

                for _, u in ipairs(E.Frame.Units) do
                    if value then
                        UnregisterUnitWatch(u)
                    else
                        RegisterUnitWatch(u)
                    end
                end

                E.Frame:Reposition()
                E.Frame:Redraw()
            end,
            get = function () return E.db.profile.showAllUnits end
        },
        enabled = {
            name = L["config.enabled.name"],
            desc = L["config.enabled.desc"],
            type = "toggle",
            order = 1,
            set = function (_, value) E.Frame:SetVisibility(value) end,
            get = function () return E.db.profile.enabled end
        },
        isLocked = {
            name = L["config.isLocked.name"],
            desc = L["config.isLocked.desc"],
            type = "toggle",
            order = 2,
            set = function (_, value) E.Frame:SetLock(value) end,
            get = function () return E.db.profile.isLocked end
        }
    }
}