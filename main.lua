local addon = ...

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
-- endregion

-- region Create config window
local media = LibStub("LibSharedMedia-3.0")
LibStub("AceConfig-3.0"):RegisterOptionsTable(addon, {
    name = addon,
    type = "group",
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
        unitWidth = {
            name = "Unit width",
            desc = "The width of the unit.",
            type = "range",
            min = 1,
            softMax = 1024,
            order = 2,
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
            order = 3,
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
            order = 4,
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
            order = 5,
            set = function (_, value)
                BlessingHelperConfig.verticalPadding = value
                BlessingHelper.Frame:Redraw()
            end,
            get = function () return BlessingHelperConfig.verticalPadding end
        },
        backgroundColor = {
            name = "Background color",
            desc = "The color of the background.",
            type = "color",
            hasAlpha = true,
            order = 6,
            set = function (_, ...)
                BlessingHelperConfig.backgroundColor = {...}
                --BlessingHelper.Frame:SetBackdropColor(...)
                BlessingHelper.Frame.Background:SetVertexColor(...)
            end,
            get = function () return BlessingHelperConfig.backgroundColor[1], BlessingHelperConfig.backgroundColor[2], BlessingHelperConfig.backgroundColor[3], BlessingHelperConfig.backgroundColor[4] end
        },
        unitFont = {
            name = "Unit font",
            desc = "The font to use to display the unit.",
            type = "select",
            values = media:HashTable("font"),
            dialogControl = "LSM30_Font",
            order = 7,
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
            order = 8,
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
            order = 9,
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
            order = 10,
            set = function (_, value)
                BlessingHelperConfig.durationFontSize = value
                BlessingHelper.Frame:Redraw()
            end,
            get = function () return BlessingHelperConfig.durationFontSize end
        },
    }
})
LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addon)
-- endregion