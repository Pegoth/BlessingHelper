local addon = ...

-- region Libraries
local media = LibStub("LibSharedMedia-3.0")
local aceConfig = LibStub("AceConfig-3.0")
local aceConfigDialog = LibStub('AceConfigDialog-3.0')
-- endregion

-- region Global functions
function BlessingHelper.CreateBackdrop(frame, r, g, b, a)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\"..addon.."\\Textures\\Background",
        insets = {
            left = 0,
            top = 0,
            right = 0,
            bottom = 0
        }
    })
    frame:SetBackdropColor(r, g, b, a)
end

function BlessingHelper.GetSpell(class, spell, defaultEnabled, defaultPriority)
    if BlessingHelperConfig.spells == nil or BlessingHelperConfig.spells[class] == nil or BlessingHelperConfig.spells[class][spell] == nil then
        return defaultEnabled, defaultPriority
    end

    return BlessingHelperConfig.spells[class][spell].enabled, BlessingHelperConfig.spells[class][spell].priority
end

function BlessingHelper.SetSpell(class, spell, enabled, priority)
    if BlessingHelperConfig.spells == nil then
        BlessingHelperConfig.spells = {}
    end
    if BlessingHelperConfig.spells[class] == nil then
        BlessingHelperConfig.spells[class] = {}
    end
    if BlessingHelperConfig.spells[class][spell] == nil then
        BlessingHelperConfig.spells[class][spell] = {}
    end

    BlessingHelperConfig.spells[class][spell].enabled = enabled
    BlessingHelperConfig.spells[class][spell].priority = priority
end
-- endregion

-- region Create config window
local config = {
    name = addon,
    type = "group",
    args = {
        frame = {
            name = "Frame settings",
            type = "group",
            order= 1,
            args = {
                isLocked = {
                    name = "Locked",
                    desc = "Whether the moving/resizing frame is shown or not.",
                    type = "toggle",
                    order = 1,
                    set = function (_, value)
                        BlessingHelper.Frame:SetLock(value)
                    end,
                    get = function () return BlessingHelperConfig.isLocked end
                },
                backgroundColor = {
                    name = "Background color",
                    desc = "The color of the background.",
                    type = "color",
                    hasAlpha = true,
                    order = 2,
                    set = function (_, ...)
                        BlessingHelperConfig.backgroundColor = {...}
                        BlessingHelper.Frame.Background:SetVertexColor(...)
                    end,
                    get = function () return BlessingHelperConfig.backgroundColor[1], BlessingHelperConfig.backgroundColor[2], BlessingHelperConfig.backgroundColor[3], BlessingHelperConfig.backgroundColor[4] end
                }
            }
        },
        units = {
            name = "Unit settings",
            type = "group",
            order = 2,
            args = {
                unitWidth = {
                    name = "Unit width",
                    desc = "The width of the unit.",
                    type = "range",
                    min = 1,
                    softMax = 1024,
                    order = 1,
                    set = function (_, value)
                        BlessingHelperConfig.unitWidth = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.unitWidth end
                },
                unitHeight = {
                    name = "Unit height",
                    desc = "The height of the unit.",
                    type = "range",
                    min = 1,
                    softMax = 512,
                    order = 2,
                    set = function (_, value)
                        BlessingHelperConfig.unitHeight = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.unitHeight end
                },
                horizontalPadding = {
                    name = "Horizontal padding",
                    desc = "The pixels between units on the Y coord.",
                    type = "range",
                    min = 0,
                    softMax = 10,
                    order = 3,
                    set = function (_, value)
                        BlessingHelperConfig.horizontalPadding = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.horizontalPadding end
                },
                verticalPadding = {
                    name = "Vertical padding",
                    desc = "The pixels between units on the Y coord.",
                    type = "range",
                    min = 0,
                    softMax = 10,
                    order = 4,
                    set = function (_, value)
                        BlessingHelperConfig.verticalPadding = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.verticalPadding end
                },
                unitFont = {
                    name = "Unit font",
                    desc = "The font to use to display the unit.",
                    type = "select",
                    values = media:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    order = 5,
                    set = function (_, value)
                        BlessingHelperConfig.unitFont = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.unitFont end
                },
                unitFontSize = {
                    name = "Unit font size",
                    desc = "The size of the font that is used to display the unit.",
                    type = "range",
                    min = 1,
                    softMax = 64,
                    order = 6,
                    set = function (_, value)
                        BlessingHelperConfig.unitFontSize = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.unitFontSize end
                },
                durationFont = {
                    name = "Duration font",
                    desc = "The font to use to display the duration.",
                    type = "select",
                    values = media:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    order = 7,
                    set = function (_, value)
                        BlessingHelperConfig.durationFont = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.durationFont end
                },
                durationFontSize = {
                    name = "Duration font size",
                    desc = "The size of the font that is used to display the duration.",
                    type = "range",
                    min = 1,
                    softMax = 64,
                    order = 8,
                    set = function (_, value)
                        BlessingHelperConfig.durationFontSize = value
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.durationFontSize end
                },
                buffedColor = {
                    name = "Buffed color",
                    desc = "Color of units that are buffed and no action needed.",
                    type = "color",
                    hasAlpha = false,
                    order = 9,
                    set = function (_, ...)
                        BlessingHelperConfig.buffedColor = {...}
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.buffedColor[1], BlessingHelperConfig.buffedColor[2], BlessingHelperConfig.buffedColor[3] end
                },
                unbuffedColor = {
                    name = "Unbuffed color",
                    desc = "Color of units  that are not buffed and in range.",
                    type = "color",
                    hasAlpha = false,
                    order = 10,
                    set = function (_, ...)
                        BlessingHelperConfig.unbuffedColor = {...}
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.unbuffedColor[1], BlessingHelperConfig.unbuffedColor[2], BlessingHelperConfig.unbuffedColor[3] end
                },
                outOfRangeColor = {
                    name = "Out of range color",
                    desc = "Color of units that are out of range.",
                    type = "color",
                    hasAlpha = false,
                    order = 11,
                    set = function (_, ...)
                        BlessingHelperConfig.outOfRangeColor = {...}
                        BlessingHelper.Frame:Redraw()
                    end,
                    get = function () return BlessingHelperConfig.outOfRangeColor[1], BlessingHelperConfig.outOfRangeColor[2], BlessingHelperConfig.outOfRangeColor[3] end
                }
            }
        },
        spells = {
            name = "Spells",
            type = "group",
            order = 3,
            args = {
                useGreater = {
                    name = "Use Greater blessings",
                    desc = "When checked will cast Greater Blessing of ... instead of Blessing of ...",
                    type = "toggle",
                    order = 1,
                    set = function (_, value)
                        if not BlessingHelperConfig.spells then
                            BlessingHelperConfig.spells = {}
                        end
                        BlessingHelperConfig.spells.useGreater = value
                    end,
                    get = function ()
                        if not BlessingHelperConfig.spells then
                            BlessingHelperConfig.spells = {}
                        end
                        return BlessingHelperConfig.spells.useGreater
                    end
                }
            }
        }
    }
}

for i, class in ipairs(BlessingHelper.Classes) do
    local args = {}

    for j, blessing in ipairs(BlessingHelper.Blessings) do
        args[blessing] = {
            name = blessing,
            type = "group",
            inline = true,
            order = select(2, BlessingHelper.GetSpell(class, blessing, nil, j)),
            args = {
                enabled = {
                    name = "Enabled",
                    desc = "Whether the buff is allowed or not for this class.",
                    type = "toggle",
                    order = 1,
                    set = function (_, value)
                        local _, p = BlessingHelper.GetSpell(class, blessing, true, j)
                        BlessingHelper.SetSpell(class, blessing, value, p)
                    end,
                    get = function () return BlessingHelper.GetSpell(class, blessing, true) end
                },
                priority = {
                    name = "Priority",
                    desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the class.",
                    type = "range",
                    step = 1,
                    min = 1,
                    max = #BlessingHelper.Blessings,
                    order = 2,
                    set = function (_, value)
                        local e, _ = BlessingHelper.GetSpell(class, blessing, true, j)
                        BlessingHelper.SetSpell(class, blessing, e, value)
                    end,
                    get = function () return select(2, BlessingHelper.GetSpell(class, blessing, nil, j)) end
                },
                up = {
                    name = "Up",
                    type = "execute",
                    order = 3,
                    func = function ()
                        local e, p = BlessingHelper.GetSpell(class, blessing, true, j)
                        if p > 1 then
                            BlessingHelper.SetSpell(class, blessing, e, p - 1)
                        end
                    end
                },
                down = {
                    name = "Down",
                    type = "execute",
                    order = 4,
                    func = function ()
                        local e, p = BlessingHelper.GetSpell(class, blessing, true, j)
                        if p < 6 then
                            BlessingHelper.SetSpell(class, blessing, e, p + 1)
                        end
                    end
                }
            }
        }
    end

    config.args.spells.args[class] = {
        name = class,
        type = "group",
        order = 1 + i,
        args = args
    }
end

aceConfig:RegisterOptionsTable(addon, config)
aceConfigDialog:AddToBlizOptions(addon)

local f = CreateFrame("frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function ()
    if InfinitySearch ~= nil then
        InfinitySearch:RegisterAddonFunction("Extras: BlessingHelper", "Options", nil, function ()
            aceConfigDialog:Open(addon)
        end)

        InfinitySearch:RegisterAddonFunction("Extras: BlessingHelper", "Lock", nil, function ()
            BlessingHelper.Frame:ToggleLock()
        end)

        f:UnregisterAllEvents()
    end
end)
-- endregion