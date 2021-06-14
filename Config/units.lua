local _, addon = ...
local E = addon.Engine
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
local M = LibStub("LibSharedMedia-3.0")

addon.Config.args.units = {
    name = L["config.units.name"],
    type = "group",
    order = 4,
    args = {
        size = {
            name = L["config.units.size.name"],
            type = "group",
            inline = true,
            order = 1,
            args = {
                unitWidth = {
                    name = L["config.units.size.unitWidth.name"],
                    desc = L["config.units.size.unitWidth.desc"],
                    type = "range",
                    min = 1,
                    softMax = 1024,
                    order = 1,
                    set = function (_, value)
                        E.db.profile.unitWidth = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unitWidth end
                },
                unitHeight = {
                    name = L["config.units.size.unitHeight.name"],
                    desc = L["config.units.size.unitHeight.desc"],
                    type = "range",
                    min = 1,
                    softMax = 512,
                    order = 2,
                    set = function (_, value)
                        E.db.profile.unitHeight = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unitHeight end
                },
                horizontalPadding = {
                    name = L["config.units.size.horizontalPadding.name"],
                    desc = L["config.units.size.horizontalPadding.desc"],
                    type = "range",
                    min = 0,
                    softMax = 10,
                    order = 3,
                    set = function (_, value)
                        E.db.profile.horizontalPadding = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.horizontalPadding end
                },
                verticalPadding = {
                    name = L["config.units.size.verticalPadding.name"],
                    desc = L["config.units.size.verticalPadding.desc"],
                    type = "range",
                    min = 0,
                    softMax = 10,
                    order = 4,
                    set = function (_, value)
                        E.db.profile.verticalPadding = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.verticalPadding end
                }
            }
        },
        font = {
            name = L["config.units.font.name"],
            type = "group",
            inline = true,
            order = 2,
            args = {
                unitFont = {
                    name = L["config.units.font.unitFont.name"],
                    desc = L["config.units.font.unitFont.desc"],
                    type = "select",
                    values = M:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    order = 1,
                    set = function (_, value)
                        E.db.profile.unitFont = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unitFont end
                },
                unitFontSize = {
                    name = L["config.units.font.unitFontSize.name"],
                    desc = L["config.units.font.unitFontSize.desc"],
                    type = "range",
                    step = 1,
                    min = 1,
                    softMax = 64,
                    order = 2,
                    set = function (_, value)
                        E.db.profile.unitFontSize = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unitFontSize end
                },
                durationFont = {
                    name = L["config.units.font.durationFont.name"],
                    desc = L["config.units.font.durationFont.desc"],
                    type = "select",
                    values = M:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    order = 3,
                    set = function (_, value)
                        E.db.profile.durationFont = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.durationFont end
                },
                durationFontSize = {
                    name = L["config.units.font.durationFontSize.name"],
                    desc = L["config.units.font.durationFontSize.desc"],
                    type = "range",
                    step = 1,
                    min = 1,
                    softMax = 64,
                    order = 4,
                    set = function (_, value)
                        E.db.profile.durationFontSize = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.durationFontSize end
                }
            }
        },
        color = {
            name = L["config.units.color.name"],
            type = "group",
            inline = true,
            order = 3,
            args = {
                buffedColor = {
                    name = L["config.units.color.buffedColor.name"],
                    desc = L["config.units.color.buffedColor.desc"],
                    type = "color",
                    hasAlpha = false,
                    order = 1,
                    set = function (_, ...)
                        E.db.profile.buffedColor = {...}
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.buffedColor[1], E.db.profile.buffedColor[2], E.db.profile.buffedColor[3] end
                },
                unbuffedColor = {
                    name = L["config.units.color.unbuffedColor.name"],
                    desc = L["config.units.color.unbuffedColor.desc"],
                    type = "color",
                    hasAlpha = false,
                    order = 2,
                    set = function (_, ...)
                        E.db.profile.unbuffedColor = {...}
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unbuffedColor[1], E.db.profile.unbuffedColor[2], E.db.profile.unbuffedColor[3] end
                },
                unbuffedPetColor = {
                    name = L["config.units.color.unbuffedPetColor.name"],
                    desc = L["config.units.color.unbuffedPetColor.desc"],
                    type = "color",
                    hasAlpha = false,
                    order = 3,
                    set = function (_, ...)
                        E.db.profile.unbuffedPetColor = {...}
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unbuffedPetColor[1], E.db.profile.unbuffedPetColor[2], E.db.profile.unbuffedPetColor[3] end
                },
                outOfRangeColor = {
                    name = L["config.units.color.outOfRangeColor.name"],
                    desc = L["config.units.color.outOfRangeColor.desc"],
                    type = "color",
                    hasAlpha = false,
                    order = 4,
                    set = function (_, ...)
                        E.db.profile.outOfRangeColor = {...}
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.outOfRangeColor[1], E.db.profile.outOfRangeColor[2], E.db.profile.outOfRangeColor[3] end
                }
            }
        },
        other = {
            name = L["config.units.other.name"],
            type = "group",
            inline = true,
            order = 4,
            args = {
                unitLength = {
                    name = L["config.units.other.unitLength.name"],
                    desc = L["config.units.other.unitLength.desc"],
                    type = "range",
                    step = 1,
                    min = 0,
                    softMax = 12,
                    order = 1,
                    set = function (_, value)
                        E.db.profile.unitLength = value
                        E.Frame:Redraw()
                    end,
                    get = function () return E.db.profile.unitLength end
                }
            }
        }
    }
}