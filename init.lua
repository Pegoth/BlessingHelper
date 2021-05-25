local addon = ...

BlessingHelper = LibStub("AceAddon-3.0"):NewAddon(addon)

function BlessingHelper:OnInitialize()
    self:SetupConstants()
    self:SetupDB()
    self.SetupConfig()
    self.SetupInfinitySearch()
end

function BlessingHelper:OnEnable()
    self.SetupFrame()
end

function BlessingHelper:SetupConstants()
    self.UnitIds = {
        {
            id = "player"
        },
        {
            id = "party",
            max = 4
        },
        {
            id = "raid",
            max = 40
        },
        {
            id = "pet"
        },
        {
            id = "partypet",
            max = 4
        },
        {
            id = "raidpet",
            max = 40
        }
    }
    self.Classes = {
        "Druid",
        "Hunter",
        "Mage",
        "Paladin",
        "Priest",
        "Rogue",
        "Shaman",
        "Warlock",
        "Warrior"
    }
    self.Blessings = {
        "Blessing of Kings",
        "Blessing of Wisdom",
        "Blessing of Might",
        "Blessing of Light",
        "Blessing of Salvation",
        "Blessing of Sanctuary"
    }
    self.RangeCheckSpell = "Blessing of Wisdom"
end

function BlessingHelper:SetupDB()
    local defaults = {
        profile = {
            isLocked = false,
            backgroundColor = {0, 0, 0, 0.5},
            maximumRows = 10,
            unitWidth = 100,
            unitHeight = 20,
            horizontalPadding = 1,
            verticalPadding = 1,
            unitFont = "PT Sans Narrow",
            unitFontSize = 10,
            durationFont = "PT Sans Narrow",
            durationFontSize = 12,
            buffedColor = {0, 1, 0},
            unbuffedColor = {1, 0, 0},
            outOfRangeColor = {0.1, 0.1, 0.1},
            spells = {
                useGreater = true,
                ["*"] = {}
            }
        }
    }

    for priority, blessing in ipairs(self.Blessings) do
        defaults.profile.spells["*"][blessing] = {
            enabled = true,
            priority = priority
        }
    end

    self.db = LibStub("AceDB-3.0"):New("BlessingHelperDB", defaults, true)
end

function BlessingHelper:SetupConfig()
    local media = LibStub("LibSharedMedia-3.0")
    local aceConfig = LibStub("AceConfig-3.0")
    local aceConfigDialog = LibStub("AceConfigDialog-3.0")

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
                            self.Frame:SetLock(value)
                        end,
                        get = function () return self.db.profile.isLocked end
                    },
                    backgroundColor = {
                        name = "Background color",
                        desc = "The color of the background.",
                        type = "color",
                        hasAlpha = true,
                        order = 2,
                        set = function (_, ...)
                            self.db.profile.backgroundColor = {...}
                            self.Frame.Background:SetColorTexture(...)
                        end,
                        get = function () return self.db.profile.backgroundColor[1], self.db.profile.backgroundColor[2], self.db.profile.backgroundColor[3], self.db.profile.backgroundColor[4] end
                    },
                    maximumRows = {
                        name = "Maximum rows",
                        desc = "The maximum amount of units to display in a column.",
                        type = "range",
                        step = 1,
                        min = 1,
                        max = BlessingHelper.NumUnitIds,
                        order = 3,
                        set = function (_, value)
                            self.db.profile.maximumRows = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.maximumRows end
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
                            self.db.profile.unitWidth = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.unitWidth end
                    },
                    unitHeight = {
                        name = "Unit height",
                        desc = "The height of the unit.",
                        type = "range",
                        min = 1,
                        softMax = 512,
                        order = 2,
                        set = function (_, value)
                            self.db.profile.unitHeight = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.unitHeight end
                    },
                    horizontalPadding = {
                        name = "Horizontal padding",
                        desc = "The pixels between units on the Y coord.",
                        type = "range",
                        min = 0,
                        softMax = 10,
                        order = 3,
                        set = function (_, value)
                            self.db.profile.horizontalPadding = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.horizontalPadding end
                    },
                    verticalPadding = {
                        name = "Vertical padding",
                        desc = "The pixels between units on the Y coord.",
                        type = "range",
                        min = 0,
                        softMax = 10,
                        order = 4,
                        set = function (_, value)
                            self.db.profile.verticalPadding = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.verticalPadding end
                    },
                    unitFont = {
                        name = "Unit font",
                        desc = "The font to use to display the unit.",
                        type = "select",
                        values = media:HashTable("font"),
                        dialogControl = "LSM30_Font",
                        order = 5,
                        set = function (_, value)
                            self.db.profile.unitFont = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.unitFont end
                    },
                    unitFontSize = {
                        name = "Unit font size",
                        desc = "The size of the font that is used to display the unit.",
                        type = "range",
                        min = 1,
                        softMax = 64,
                        order = 6,
                        set = function (_, value)
                            self.db.profile.unitFontSize = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.unitFontSize end
                    },
                    durationFont = {
                        name = "Duration font",
                        desc = "The font to use to display the duration.",
                        type = "select",
                        values = media:HashTable("font"),
                        dialogControl = "LSM30_Font",
                        order = 7,
                        set = function (_, value)
                            self.db.profile.durationFont = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.durationFont end
                    },
                    durationFontSize = {
                        name = "Duration font size",
                        desc = "The size of the font that is used to display the duration.",
                        type = "range",
                        min = 1,
                        softMax = 64,
                        order = 8,
                        set = function (_, value)
                            self.db.profile.durationFontSize = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.durationFontSize end
                    },
                    buffedColor = {
                        name = "Buffed color",
                        desc = "Color of units that are buffed and no action needed.",
                        type = "color",
                        hasAlpha = false,
                        order = 9,
                        set = function (_, ...)
                            self.db.profile.buffedColor = {...}
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.buffedColor[1], self.db.profile.buffedColor[2], self.db.profile.buffedColor[3] end
                    },
                    unbuffedColor = {
                        name = "Unbuffed color",
                        desc = "Color of units  that are not buffed and in range.",
                        type = "color",
                        hasAlpha = false,
                        order = 10,
                        set = function (_, ...)
                            self.db.profile.unbuffedColor = {...}
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.unbuffedColor[1], self.db.profile.unbuffedColor[2], self.db.profile.unbuffedColor[3] end
                    },
                    outOfRangeColor = {
                        name = "Out of range color",
                        desc = "Color of units that are out of range.",
                        type = "color",
                        hasAlpha = false,
                        order = 11,
                        set = function (_, ...)
                            self.db.profile.outOfRangeColor = {...}
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.outOfRangeColor[1], self.db.profile.outOfRangeColor[2], self.db.profile.outOfRangeColor[3] end
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
                        set = function (_, value) self.db.profile.spells.useGreater = value end,
                        get = function () return self.db.profile.spells.useGreater end
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
                        set = function (_, value) self.db.profile.spells[class][blessing].enabled = value end,
                        get = function () return self.db.profile.spells[class][blessing].enabled end
                    },
                    priority = {
                        name = "Priority",
                        desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the class.",
                        type = "range",
                        step = 1,
                        min = 1,
                        max = #BlessingHelper.Blessings,
                        order = 2,
                        set = function (_, value) self.db.profile.spells[class][blessing].priority = value end,
                        get = function () return self.db.profile.spells[class][blessing].priority end
                    },
                    up = {
                        name = "Up",
                        type = "execute",
                        order = 3,
                        func = function ()
                            local p = self.db.profile.spells[class][blessing].priority
                            if p > 1 then
                                self.db.profile.spells[class][blessing].priority = p - 1
                            end
                        end
                    },
                    down = {
                        name = "Down",
                        type = "execute",
                        order = 4,
                        func = function ()
                            local p = self.db.profile.spells[class][blessing].priority
                            if p < 6 then
                                self.db.profile.spells[class][blessing].priority = p + 1
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

    config.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    aceConfig:RegisterOptionsTable(addon, config)
    aceConfigDialog:AddToBlizOptions(addon)
end

function BlessingHelper:SetupInfinitySearch()
    if InfinitySearch ~= nil then
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, "Options", nil, function ()
            LibStub("AceConfigDialog-3.0"):Open(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, "Lock", nil, function ()
            self.Frame:ToggleLock()
        end)

        if self.InfinitySearchSetupFrame then
            self.InfinitySearchSetupFrame:UnregisterAllEvents()
        end
    elseif not self.InfinitySearchSetupFrame then
        self.InfinitySearchSetupFrame = CreateFrame("frame")
        self.InfinitySearchSetupFrame:RegisterEvent("ADDON_LOADED")
        self.InfinitySearchSetupFrame:RegisterEvent("PLAYER_LOGIN")
        self.InfinitySearchSetupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.InfinitySearchSetupFrame:SetScript("OnEvent", function ()
           BlessingHelper:SetupInfinitySearch()
        end)
    end
end

function BlessingHelper:SetupFrame()
    self.Frame = CreateFrame("frame", nil, UIParent, "BlessingHelperFrameTemplate")
end

-- Limit name length?