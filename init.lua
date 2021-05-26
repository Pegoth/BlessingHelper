local addon = ...

BlessingHelper = LibStub("AceAddon-3.0"):NewAddon(addon)

function BlessingHelper:OnInitialize()
    self:SetupConstants()
    self:SetupDB()
    self:SetupConfig()
    self:SetupInfinitySearch()
end

function BlessingHelper:OnEnable()
    self:SetupFrame()
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

    self.NumUnitIds = 0
    for _, unitid in ipairs(self.UnitIds) do
        self.NumUnitIds = self.NumUnitIds + (unitid.max or 1)
    end
end

function BlessingHelper:SetupDB()
    local defaults = {
        profile = {
            enabled = true,
            isLocked = false,
            backgroundColor = {0, 0, 0, 0.5},
            maximumRows = 10,
            unitWidth = 100,
            unitHeight = 20,
            horizontalPadding = 1,
            verticalPadding = 1,
            unitLength = 15,
            unitFont = "PT Sans Narrow",
            unitFontSize = 10,
            durationFont = "PT Sans Narrow",
            durationFontSize = 12,
            buffedColor = {0, 1, 0},
            unbuffedColor = {1, 0, 0},
            unbuffedPetColor = {0.5, 0, 0},
            outOfRangeColor = {0.1, 0.1, 0.1},
            spells = {
                useGreater = true,
                ["*"] = {}
            },
            mainFrameAnchor = {
                point = "CENTER",
                relativePoint = "CENTER",
                x = 0,
                y = 0
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
            enabled = {
                name = "Enabled",
                desc = "Whether the frame is visible or not.",
                type = "toggle",
                order = 1,
                set = function (_, value)
                    self.db.profile.enabled = value

                    if value then
                        self.Frame:Show()
                    else
                        self.Frame:Hide()
                    end
                end,
                get = function () return self.db.profile.enabled end
            },
            isLocked = {
                name = "Locked",
                desc = "Whether the moving/resizing frame is shown or not.",
                type = "toggle",
                order = 2,
                set = function (_, value) self.Frame:SetLock(value) end,
                get = function () return self.db.profile.isLocked end
            },
            frame = {
                name = "Frame settings",
                type = "group",
                order = 3,
                args = {
                    backgroundColor = {
                        name = "Background color",
                        desc = "The color of the background.",
                        type = "color",
                        hasAlpha = true,
                        order = 1,
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
                        order = 2,
                        set = function (_, value)
                            self.db.profile.maximumRows = value
                            self.Frame:Redraw()
                        end,
                        get = function () return self.db.profile.maximumRows end
                    },
                    special = {
                        name = "Special",
                        type = "group",
                        inline = true,
                        order = 3,
                        args = {
                            resetPosition = {
                                name = "Reset position",
                                desc = "Resets the position of the main frame.",
                                type = "execute",
                                order = 1,
                                func = function ()
                                    self.db.profile.mainFrameAnchor.point = "CENTER"
                                    self.db.profile.mainFrameAnchor.relativePoint = "CENTER"
                                    self.db.profile.mainFrameAnchor.x = 0
                                    self.db.profile.mainFrameAnchor.y = 0

                                    self.Frame:ClearAllPoints()
                                    self.Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                                end
                            }
                        }
                    }
                }
            },
            units = {
                name = "Unit settings",
                type = "group",
                order = 3,
                args = {
                    size = {
                        name = "Size",
                        type = "group",
                        inline = true,
                        order = 1,
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
                            }
                        }
                    },
                    font = {
                        name = "Font",
                        type = "group",
                        inline = true,
                        order = 2,
                        args = {
                            unitFont = {
                                name = "Unit font",
                                desc = "The font to use to display the unit.",
                                type = "select",
                                values = media:HashTable("font"),
                                dialogControl = "LSM30_Font",
                                order = 1,
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
                                order = 2,
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
                                order = 3,
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
                                order = 4,
                                set = function (_, value)
                                    self.db.profile.durationFontSize = value
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.durationFontSize end
                            }
                        }
                    },
                    color = {
                        name = "Color",
                        type = "group",
                        inline = true,
                        order = 3,
                        args = {
                            buffedColor = {
                                name = "Buffed color",
                                desc = "Color of units that are buffed and no action needed.",
                                type = "color",
                                hasAlpha = false,
                                order = 1,
                                set = function (_, ...)
                                    self.db.profile.buffedColor = {...}
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.buffedColor[1], self.db.profile.buffedColor[2], self.db.profile.buffedColor[3] end
                            },
                            unbuffedColor = {
                                name = "Unbuffed color",
                                desc = "Color of units that are not buffed and in range.",
                                type = "color",
                                hasAlpha = false,
                                order = 2,
                                set = function (_, ...)
                                    self.db.profile.unbuffedColor = {...}
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.unbuffedColor[1], self.db.profile.unbuffedColor[2], self.db.profile.unbuffedColor[3] end
                            },
                            unbuffedPetColor = {
                                name = "Unbuffed pet color",
                                desc = "Color of pet units that are not buffed and in range.",
                                type = "color",
                                hasAlpha = false,
                                order = 3,
                                set = function (_, ...)
                                    self.db.profile.unbuffedPetColor = {...}
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.unbuffedPetColor[1], self.db.profile.unbuffedPetColor[2], self.db.profile.unbuffedPetColor[3] end
                            },
                            outOfRangeColor = {
                                name = "Out of range color",
                                desc = "Color of units that are out of range.",
                                type = "color",
                                hasAlpha = false,
                                order = 4,
                                set = function (_, ...)
                                    self.db.profile.outOfRangeColor = {...}
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.outOfRangeColor[1], self.db.profile.outOfRangeColor[2], self.db.profile.outOfRangeColor[3] end
                            }
                        }
                    },
                    other = {
                        name = "Other",
                        type = "group",
                        inline = true,
                        order = 4,
                        args = {
                            unitLength = {
                                name = "Unit length",
                                desc = "The maximum length of the unit name. Set to 0 to not display names at all.",
                                type = "range",
                                min = 0,
                                softMax = 12,
                                order = 1,
                                set = function (_, value)
                                    self.db.profile.unitLength = value
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.unitLength end
                            }
                        }
                    }
                }
            },
            spells = {
                name = "Spells",
                type = "group",
                order = 4,
                args = {
                    useGreater = {
                        name = "Use Greater blessings",
                        desc = "When checked will cast Greater Blessing of ... instead of Blessing of ...",
                        type = "toggle",
                        order = 1,
                        set = function (_, value) self.db.profile.spells.useGreater = value end,
                        get = function () return self.db.profile.spells.useGreater end
                    },
                    special = {
                        name = "Special",
                        type = "group",
                        inline = true,
                        order = 2,
                        args = {
                            resetPosition = {
                                name = "Reset",
                                desc = "Resets the settings of the spells/classes to their default.",
                                type = "execute",
                                order = 1,
                                func = function ()
                                    local useGreater = self.db.profile.spells.useGreater
                                    wipe(self.db.profile.spells)
                                    self.db.profile.spells.useGreater = useGreater
                                end
                            }
                        }
                    }
                }
            }
        }
    }

    local function SetPriority(class, blessing, new)
        if new >= 1 and new <= #self.Blessings then
            local old = self.db.profile.spells[class][blessing].priority

            if old ~= new then
               local buf = {}
                for k, v in pairs(self.db.profile.spells[class]) do
                    table.insert(buf, {k = k, v = v})
                end

                if old < new then
                    table.sort(buf, function (a, b) return a.v.priority < b.v.priority end)
                    for _, kv in ipairs(buf) do
                        if kv.v.priority > old and kv.v.priority <= new then
                            kv.v.priority = kv.v.priority - 1
                        end
                    end
                else
                    table.sort(buf, function (a, b) return a.v.priority > b.v.priority end)
                    for _, kv in ipairs(buf) do
                        if kv.v.priority < old and kv.v.priority >= new then
                            kv.v.priority = kv.v.priority + 1
                        end
                    end
                end

                self.db.profile.spells[class][blessing].priority = new
            end
        end
    end

    for i, class in ipairs(BlessingHelper.Classes) do
        local args = {}

        for _, blessing in ipairs(BlessingHelper.Blessings) do
            args[blessing] = {
                name = blessing,
                type = "group",
                inline = true,
                order = self.db.profile.spells[class][blessing].priority,
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
                        set = function (_, value) SetPriority(class, blessing, value) end,
                        get = function () return self.db.profile.spells[class][blessing].priority end
                    },
                    up = {
                        name = "Up",
                        type = "execute",
                        order = 3,
                        func = function () SetPriority(class, blessing, self.db.profile.spells[class][blessing].priority - 1) end
                    },
                    down = {
                        name = "Down",
                        type = "execute",
                        order = 4,
                        func = function () SetPriority(class, blessing, self.db.profile.spells[class][blessing].priority + 1) end
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

    aceConfig:RegisterOptionsTable(addon, config, { "bh", "blessinghelper" })
    aceConfigDialog:AddToBlizOptions(addon)
end

function BlessingHelper:SetupInfinitySearch()
    if InfinitySearch ~= nil then
        local aceConfigRegistry = LibStub("AceConfigRegistry-3.0")

        InfinitySearch:RegisterAddonFunction("Extras: "..addon, "Options", nil, function ()
            LibStub("AceConfigDialog-3.0"):Open(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, "Lock", nil, function ()
            self.Frame:ToggleLock()
            aceConfigRegistry:NotifyChange(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, "Toggle", nil, function ()
            self.db.profile.enabled = not self.db.profile.enabled
            if self.db.profile.enabled then
                self.Frame:Show()
            else
                self.Frame:Hide()
            end
            aceConfigRegistry:NotifyChange(addon)
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
    self.Frame:ClearAllPoints()
    self.Frame:SetPoint(self.db.profile.mainFrameAnchor.point, UIParent, self.db.profile.mainFrameAnchor.relativePoint, self.db.profile.mainFrameAnchor.x, self.db.profile.mainFrameAnchor.y)

    if not self.db.profile.enabled then
        self.Frame:Hide()
    end
end

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

-- Limit name length?