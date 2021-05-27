local addon = ...

BlessingHelper = LibStub("AceAddon-3.0"):NewAddon(addon)

function BlessingHelper:OnInitialize()
    self:SetupClasses()
    self:SetupConstants()
    self:SetupLocales()
    self:SetupHelpers()
    self:SetupDB()
    self:SetupConfig()
    self:SetupInfinitySearch()
    self:SetupMinimapIcon()
end

function BlessingHelper:OnEnable()
    self:SetupFrame()
end

function BlessingHelper:SetupClasses()
    self.Blessing = {}
    function self.Blessing:New(key, normal, greater)
        local buf = {
            key = key,
            normal = {
                id = normal
            },
            greater = {
                id = greater
            }
        }

        buf.normal.name, _, buf.normal.icon = GetSpellInfo(normal)
        buf.greater.name, _, buf.greater.icon = GetSpellInfo(greater)

        setmetatable(buf, self)
        self.__index = self
        return buf
    end
    function self.Blessing:Copy(blessing)
        local buf = {
            key = blessing.key,
            normal = {
                id = blessing.normal.id,
                name = blessing.normal.name,
                icon = blessing.normal.icon
            },
            greater = {
                id = blessing.greater.id,
                name = blessing.greater.name,
                icon = blessing.greater.icon
            }
        }

        setmetatable(buf, self)
        self.__index = self
        return buf
    end
    function self.Blessing:Equals(buffName)
        return self.normal.name == buffName or self.greater.name == buffName
    end
    function self.Blessing:IsUsable(greater)
        local usable, noMana = IsUsableSpell(greater and self.greater.id or self.normal.id)
        return usable or noMana
    end
    function self.Blessing:IsInRange(unit)
        return IsSpellInRange(self.normal.name, unit)
    end
    function self.Blessing:Contains(blessings, own)
        for i = 1, #blessings do
            if own == nil or own == true and blessings[i].unitCaster == "player" or own == false and blessings[i].unitCaster ~= "player" then
                if blessings[i].name == self.normal.name then
                    return self.normal.name, blessings[i].unitCaster == "player"
                elseif blessings[i].name == self.greater.name then
                    return self.greater.name, blessings[i].unitCaster == "player"
                end
            end
        end
    end
    function self.Blessing:Spell(allowGreater)
        return (allowGreater or self.isGreater) and self:IsUsable(true) and self.greater or self.normal
    end
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
    self.NumUnitIds = #self.UnitIds
    self.Blessings = {
        self.Blessing:New("Kings", 20217, 25898),
        self.Blessing:New("Wisdom", 25290, 25918),
        self.Blessing:New("Might", 25291, 25916),
        self.Blessing:New("Light", 19979, 25890),
        self.Blessing:New("Salvation", 1038, 25895),
        self.Blessing:New("Sanctuary", 20914, 25899)
    }
    self.RangeCheckSpell = self.Blessings[1]
end

function BlessingHelper:SetupLocales()
    self.L = LibStub("AceLocale-3.0"):GetLocale(addon)
end

function BlessingHelper:SetupHelpers()
    function self.Contains(tbl, value)
        if type(tbl) ~= "table" then
            return false
        end

        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end

        return false
    end
    function self.CreateBackdrop(frame, r, g, b, a)
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
    function self:IsBlessing(buffName)
        for _, blessing in ipairs(self.Blessings) do
            if blessing:Equals(buffName) then
                return blessing
            end
        end
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
            unitLength = 12,
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
            overridesConfig = {
                enabled = true,
                name = "",
                names = {}
            },
            overrides = {
                ["*"] = {
                    enabled = true
                }
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
        defaults.profile.spells["*"][blessing.key] = {
            enabled = true,
            priority = priority
        }
        defaults.profile.overrides["*"][blessing.key] = {
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
                    x = {
                        name = "X",
                        desc = "The position of the frame.",
                        type = "range",
                        softMin = -math.floor(UIParent:GetWidth()),
                        softMax = math.floor(UIParent:GetWidth()),
                        order = 3,
                        set = function (_, value)
                            self.db.profile.mainFrameAnchor.x = value

                            self.Frame:ClearAllPoints()
                            self.Frame:SetPoint(self.db.profile.mainFrameAnchor.point, UIParent, self.db.profile.mainFrameAnchor.relativePoint, self.db.profile.mainFrameAnchor.x, self.db.profile.mainFrameAnchor.y)
                        end,
                        get = function () return self.db.profile.mainFrameAnchor.x end
                    },
                    y = {
                        name = "Y",
                        desc = "The position of the frame.",
                        type = "range",
                        softMin = -math.floor(UIParent:GetHeight()),
                        softMax = math.floor(UIParent:GetHeight()),
                        order = 4,
                        set = function (_, value)
                            self.db.profile.mainFrameAnchor.y = value

                            self.Frame:ClearAllPoints()
                            self.Frame:SetPoint(self.db.profile.mainFrameAnchor.point, UIParent, self.db.profile.mainFrameAnchor.relativePoint, self.db.profile.mainFrameAnchor.x, self.db.profile.mainFrameAnchor.y)
                        end,
                        get = function () return self.db.profile.mainFrameAnchor.y end
                    },
                    special = {
                        name = "Special",
                        type = "group",
                        inline = true,
                        order = 5,
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
                                step = 1,
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
                                step = 1,
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
                                step = 1,
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
            help = {
                name = "Help",
                type = "group",
                order = 101,
                args = {
                    spell = {
                        name = "Blessings",
                        type = "header",
                        order = 1
                    },
                    spellDesc = {
                        name = "Which blessing will be cast is based on three factors (in order):\n  \124cffffff001.)\124r If the unit already has a buff from the player or one expired it will be choosen.\n  \124cffffff002.)\124r If the unit name exists in the Spell overrides (and both the Spell overrides and the specific override is enabled) that setting will be used.\n  \124cffffff003.)\124r Based on the unit class from the Spells settings.",
                        type = "description",
                        order = 2
                    },
                    buttons = {
                        name = "Buttons",
                        type = "header",
                        order = 3
                    },
                    buttonsDesc = {
                        name = "There are 3 mouse button action available for each unit:\n  \124cffffff00Left click:\124r Smart cast the blessing based on the description above.\n  \124cffffff00Right click:\124r Cast the blessing based on the points \124cffffff002.\124r and \124cffffff003.\124r mentioned above (meaning it will ignore the current buff).\n  \124cffffff00Middle click:\124r Target the unit",
                        type = "description",
                        order = 4
                    },
                    combat = {
                        name = "Combat",
                        type = "header",
                        order = 5
                    },
                    combatDesc = {
                        name = "In combat the logic is suspended, meaning that left and right click will cast the last set values.\nUnits leaving party/raid will be hidden during combat, but the main frame will not be re-formatted (leaving gaps).\nUnits joining party/raid during combat will be displayed, but can be out of frame when the frame is locked and the left/right click might not work or cast wrong blessings.",
                        type = "description",
                        order = 6
                    },
                    other = {
                        name = "Other",
                        type = "header",
                        order = 7
                    },
                    otherDesc = {
                        name = "The unlocked frame shows the size of maximum amount of units visible at once including pets. In any normal raid/party that size will never be reached.",
                        type = "description",
                        order = 8
                    },
                }
            }
        }
    }

    local function AddSpells()
        config.args.spells = {
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
                                AddSpells()
                            end
                        }
                    }
                }
            },
        }

        -- Moves all priorities of blessings down/up when one blessing is moved to a specific priority
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

        for i, class in ipairs(CLASS_SORT_ORDER) do
            config.args.spells.args[class] = {
                name = LOCALIZED_CLASS_NAMES_MALE[class],
                type = "group",
                order = 1 + i,
                args = {}
            }

            for _, blessing in ipairs(BlessingHelper.Blessings) do
                config.args.spells.args[class].args[blessing.key] = {
                    name = blessing.normal.name,
                    type = "group",
                    inline = true,
                    order = self.db.profile.spells[class][blessing.key].priority,
                    args = {
                        enabled = {
                            name = "Enabled",
                            desc = "Whether the buff is allowed or not for this class.",
                            type = "toggle",
                            order = 1,
                            set = function (_, value) self.db.profile.spells[class][blessing.key].enabled = value end,
                            get = function () return self.db.profile.spells[class][blessing.key].enabled end
                        },
                        priority = {
                            name = "Priority",
                            desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the unit.",
                            type = "range",
                            step = 1,
                            min = 1,
                            max = #BlessingHelper.Blessings,
                            order = 2,
                            set = function (_, value)
                                SetPriority(class, blessing.key, value)
                                AddSpells()
                            end,
                            get = function () return self.db.profile.spells[class][blessing.key].priority end
                        },
                        up = {
                            name = "Up",
                            type = "execute",
                            order = 3,
                            func = function ()
                                SetPriority(class, blessing.key, self.db.profile.spells[class][blessing.key].priority - 1)
                                AddSpells()
                            end
                        },
                        down = {
                            name = "Down",
                            type = "execute",
                            order = 4,
                            func = function ()
                                SetPriority(class, blessing.key, self.db.profile.spells[class][blessing.key].priority + 1)
                                AddSpells()
                            end
                        }
                    }
                }
            end
        end
    end
    AddSpells()

    local function AddOverrides()
        config.args.overrides = {
            name = "Spell overrides",
            type = "group",
            order = 5,
            args = {
                enabled = {
                    name = "Enabled",
                    desc = "Whether the overrides are enabled or not.",
                    type = "toggle",
                    order = 1,
                    set = function (_, value) self.db.profile.overridesConfig.enabled = value end,
                    get = function () return self.db.profile.overridesConfig.enabled end
                },
                add = {
                    name = "Add",
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        name = {
                            name = "Name",
                            desc = "The name of the character.",
                            type = "input",
                            order = 1,
                            set = function (_, value)
                                self.db.profile.overridesConfig.name = value
                            end,
                            get = function () return self.db.profile.overridesConfig.name end
                        },
                        getTarget = {
                            name = "Get target",
                            desc = "Gets the name of the current target or the player if no target.",
                            type = "execute",
                            order = 2,
                            func = function () self.db.profile.overridesConfig.name = UnitName("target") or UnitName("player") end
                        },
                        add = {
                            name = "Add",
                            desc = "Adds a new override with the current name.",
                            type = "execute",
                            order = 3,
                            func = function ()
                                if not self.Contains(self.db.profile.overridesConfig.names, self.db.profile.overridesConfig.name) then
                                    table.insert(self.db.profile.overridesConfig.names, self.db.profile.overridesConfig.name)
                                    AddOverrides()
                                end
                                self.db.profile.overridesConfig.name = ""
                            end
                        }
                    }
                },
                special = {
                    name = "Special",
                    type = "group",
                    inline = true,
                    order = 3,
                    args = {
                        resetPosition = {
                            name = "Reset",
                            desc = "Resets the settings of the overrides to their default.",
                            type = "execute",
                            order = 1,
                            func = function ()
                                wipe(self.db.profile.overridesConfig.names)
                                wipe(self.db.profile.overrides)
                                AddOverrides()
                            end
                        }
                    }
                }
            }
        }

        -- Moves all priorities of blessings down/up when one blessing is moved to a specific priority
        local function SetPriority(name, blessing, new)
            if new >= 1 and new <= #self.Blessings then
                local old = self.db.profile.overrides[name][blessing].priority

                if old ~= new then
                local buf = {}
                    for k, v in pairs(self.db.profile.overrides[name]) do
                        if k:lower() ~= "enabled" then
                            table.insert(buf, {k = k, v = v})
                        end
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

                    self.db.profile.overrides[name][blessing].priority = new
                end
            end
        end

        local i = 1
        for _, name in ipairs(self.db.profile.overridesConfig.names) do
            config.args.overrides.args[name] = {
                name = name,
                type = "group",
                order = 3 + i,
                args = {
                    enabled = {
                        name = "Enabled",
                        desc = "Whether the override is active or not for this name.",
                        type = "toggle",
                        order = 1,
                        set = function (_, value) self.db.profile.overrides[name].enabled = value end,
                        get = function () return self.db.profile.overrides[name].enabled end
                    }
                }
            }

            for _, blessing in ipairs(BlessingHelper.Blessings) do
                config.args.overrides.args[name].args[blessing.key] = {
                    name = blessing.normal.name,
                    type = "group",
                    inline = true,
                    order = self.db.profile.overrides[name][blessing.key].priority + 1,
                    args = {
                        enabled = {
                            name = "Enabled",
                            desc = "Whether the buff is allowed or not for this name.",
                            type = "toggle",
                            order = 1,
                            set = function (_, value) self.db.profile.overrides[name][blessing.key].enabled = value end,
                            get = function () return self.db.profile.overrides[name][blessing.key].enabled end
                        },
                        priority = {
                            name = "Priority",
                            desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the unit.",
                            type = "range",
                            step = 1,
                            min = 1,
                            max = #BlessingHelper.Blessings,
                            order = 2,
                            set = function (_, value)
                                SetPriority(name, blessing.key, value)
                                AddOverrides()
                            end,
                            get = function () return self.db.profile.overrides[name][blessing.key].priority end
                        },
                        up = {
                            name = "Up",
                            type = "execute",
                            order = 3,
                            func = function ()
                                SetPriority(name, blessing.key, self.db.profile.overrides[name][blessing.key].priority - 1)
                                AddOverrides()
                            end
                        },
                        down = {
                            name = "Down",
                            type = "execute",
                            order = 4,
                            func = function ()
                                SetPriority(name, blessing.key, self.db.profile.overrides[name][blessing.key].priority + 1)
                                AddOverrides()
                            end
                        }
                    }
                }
            end

            config.args.overrides.args[name].args.remove = {
                name = "Remove",
                type = "execute",
                order = #self.Blessings + 1,
                func = function ()
                    self.db.profile.overrides[name] = nil
                    local j = 1
                    while j <= #self.db.profile.overridesConfig.names do
                        if self.db.profile.overridesConfig.names[j] == name then
                            table.remove(self.db.profile.overridesConfig.names, j)
                        else
                            j = j + 1
                        end
                    end
                    AddOverrides()
                end
            }

            i = i + 1
        end
    end
    AddOverrides()

    config.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    aceConfig:RegisterOptionsTable(addon, config, { "bh", "blessinghelper" })
    aceConfigDialog:AddToBlizOptions(addon)
end

function BlessingHelper:SetupInfinitySearch()
    if InfinitySearch ~= nil then
        local aceConfigRegistry = LibStub("AceConfigRegistry-3.0")

        InfinitySearch:RegisterAddonFunction("Extras: "..addon, self.L["infinitySearch.options"], nil, function ()
            LibStub("AceConfigDialog-3.0"):Open(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, self.L["infinitySearch.lock"], nil, function ()
            self.Frame:ToggleLock()
            aceConfigRegistry:NotifyChange(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, self.L["infinitySearch.toggle"], nil, function ()
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

    if not self.db.profile.enabled then
        self.Frame:Hide()
    end
end

function BlessingHelper:SetupMinimapIcon()
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register(addon, LibStub("LibDataBroker-1.1"):NewDataObject(addon, {
            type = "data source",
            text = addon,
            icon = 135995,
            OnClick = function(_, button)
                if InCombatLockdown() then
                    print(self.L["minimap.incombat"])
                    return
                end

                if button == "LeftButton" then
                    self.db.profile.enabled = not self.db.profile.enabled
                    if self.db.profile.enabled then
                        self.Frame:Show()
                    else
                        self.Frame:Hide()
                    end
                    LibStub("AceConfigRegistry-3.0"):NotifyChange(addon)
                elseif button == "RightButton" then
                    LibStub("AceConfigDialog-3.0"):Open(addon)
                end
            end,
            OnTooltipShow = function (tooltip)
                tooltip:AddLine(addon, 1, 1, 1)
                tooltip:AddLine(self.L["minimap.leftclick"])
                tooltip:AddLine(self.L["minimap.rightclick"])
            end
        }),
        self.db.profile.minimap
    )
end