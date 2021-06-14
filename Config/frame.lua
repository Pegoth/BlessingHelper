local _, addon = ...
local E = addon.Engine
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

addon.Config.args.frame = {
    name = L["config.frame.name"],
    type = "group",
    order = 3,
    args = {
        backgroundColor = {
            name = L["config.frame.backgroundColor.name"],
            desc = L["config.frame.backgroundColor.desc"],
            type = "color",
            hasAlpha = true,
            order = 1,
            set = function (_, ...)
                E.db.profile.backgroundColor = {...}
                E.Frame.Background:SetColorTexture(...)
            end,
            get = function () return E.db.profile.backgroundColor[1], E.db.profile.backgroundColor[2], E.db.profile.backgroundColor[3], E.db.profile.backgroundColor[4] end
        },
        maximumRows = {
            name = L["config.frame.maximumRows.name"],
            desc = L["config.frame.maximumRows.desc"],
            type = "range",
            step = 1,
            min = 1,
            max = E.NumUnitIds,
            order = 2,
            set = function (_, value)
                E.db.profile.maximumRows = value
                E.Frame:Redraw()
            end,
            get = function () return E.db.profile.maximumRows end
        },
        growth = {
            name = L["config.frame.growth.name"],
            desc = L["config.frame.growth.desc"],
            type = "select",
            sorting = {
                "topLeftToDown",
                "topRightToDown",
                "bottomLeftToUp",
                "bottomRightToUp"
            },
            values = {
                topLeftToDown = L["config.frame.growth.values.topLeftToDown"],
                topRightToDown = L["config.frame.growth.values.topRightToDown"],
                bottomLeftToUp = L["config.frame.growth.values.bottomLeftToUp"],
                bottomRightToUp = L["config.frame.growth.values.bottomRightToUp"]
            },
            style = "dropdown",
            order = 3,
            set = function (_, value)
                E.db.profile.growth = value
                E.Frame:Reposition()
                E.Frame:Redraw()
            end,
            get = function () return E.db.profile.growth end
        },
        position = {
            name = L["config.frame.position.name"],
            type = "group",
            inline = true,
            order = 4,
            args = {
                point = {
                    name = L["config.frame.position.point.name"],
                    desc = L["config.frame.position.point.desc"],
                    type = "select",
                    values = function ()
                        local buf = {}
                        for _, point in ipairs(E.AnchorPoints) do
                            buf[point] = L["config.frame.position.pointValue."..point]
                        end
                        return buf
                    end,
                    style = "dropdown",
                    order = 1,
                    set = function (_, value)
                        E.db.profile.mainFrameAnchor.point = value
                        E.Frame:Reposition()
                    end,
                    get = function () return E.db.profile.mainFrameAnchor.point end
                },
                relativeFrame = {
                    name = L["config.frame.position.relativeFrame.name"],
                    desc = L["config.frame.position.relativeFrame.desc"],
                    type = "input",
                    order = 2,
                    set = function (_, value)
                        E.db.profile.mainFrameAnchor.relativeFrame = value ~= "" and value or nil
                        E.Frame:Reposition()
                    end,
                    get = function () return E.db.profile.mainFrameAnchor.relativeFrame end
                },
                relativePoint = {
                    name = L["config.frame.position.relativePoint.name"],
                    desc = L["config.frame.position.relativePoint.desc"],
                    type = "select",
                    values = function ()
                        local buf = {}
                        for _, point in ipairs(E.AnchorPoints) do
                            buf[point] = L["config.frame.position.pointValue."..point]
                        end
                        return buf
                    end,
                    style = "dropdown",
                    order = 1,
                    set = function (_, value)
                        E.db.profile.mainFrameAnchor.relativePoint = value
                        E.Frame:Reposition()
                    end,
                    get = function () return E.db.profile.mainFrameAnchor.relativePoint end
                },
                x = {
                    name = L["config.frame.position.x.name"],
                    desc = L["config.frame.position.x.desc"],
                    type = "range",
                    softMin = -250,
                    softMax = 250,
                    order = 4,
                    set = function (_, value)
                        E.db.profile.mainFrameAnchor.x = value
                        E.Frame:Reposition()
                    end,
                    get = function () return E.db.profile.mainFrameAnchor.x end
                },
                y = {
                    name = L["config.frame.position.y.name"],
                    desc = L["config.frame.position.y.desc"],
                    type = "range",
                    softMin = -250,
                    softMax = 250,
                    order = 5,
                    set = function (_, value)
                        E.db.profile.mainFrameAnchor.y = value
                        E.Frame:Reposition()
                    end,
                    get = function () return E.db.profile.mainFrameAnchor.y end
                },
                resetPosition = {
                    name = L["config.frame.position.resetPosition.name"],
                    desc = L["config.frame.position.resetPosition.desc"],
                    type = "execute",
                    func = function ()
                        E.db.profile.mainFrameAnchor.point = "CENTER"
                        E.db.profile.mainFrameAnchor.relativeFrame = nil
                        E.db.profile.mainFrameAnchor.relativePoint = "CENTER"
                        E.db.profile.mainFrameAnchor.x = 0
                        E.db.profile.mainFrameAnchor.y = 0
                        E.Frame:Reposition()
                    end
                }
            }
        }
    }
}