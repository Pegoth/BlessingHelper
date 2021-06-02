local addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

BlessingHelper = LibStub("AceAddon-3.0"):NewAddon(addon)

function BlessingHelper:OnInitialize()
    self:SetupClasses()
    self:SetupConstants()
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
    self.NumUnitIds = 80
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
    self.Blessings = {
        self.Blessing:New("Kings", 20217, 25898),
        self.Blessing:New("Wisdom", 25290, 25918),
        self.Blessing:New("Might", 25291, 25916),
        self.Blessing:New("Light", 19979, 25890),
        self.Blessing:New("Salvation", 1038, 25895),
        self.Blessing:New("Sanctuary", 20914, 25899)
    }
    self.RangeCheckSpell = self.Blessings[1]
    self.AnchorPoints = {
        "TOPLEFT",
        "TOP",
        "TOPRIGHT",
        "RIGHT",
        "BOTTOMRIGHT",
        "BOTTOM",
        "BOTTOMLEFT",
        "LEFT",
        "CENTER"
    }
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
                relativeFrame = nil,
                relativePoint = "CENTER",
                x = 0,
                y = 0
            },
            export = {
                frame = false,
                unit = false,
                spells = true,
                overrides = true
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
    local aceSerializer = LibStub("AceSerializer-3.0")
    local libDeflate = LibStub("LibDeflate")

    local config = {
        name = addon,
        type = "group",
        args = {
            enabled = {
                name = L["config.enabled.name"],
                desc = L["config.enabled.desc"],
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
                name = L["config.isLocked.name"],
                desc = L["config.isLocked.desc"],
                type = "toggle",
                order = 2,
                set = function (_, value) self.Frame:SetLock(value) end,
                get = function () return self.db.profile.isLocked end
            },
            frame = {
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
                            self.db.profile.backgroundColor = {...}
                            self.Frame.Background:SetColorTexture(...)
                        end,
                        get = function () return self.db.profile.backgroundColor[1], self.db.profile.backgroundColor[2], self.db.profile.backgroundColor[3], self.db.profile.backgroundColor[4] end
                    },
                    maximumRows = {
                        name = L["config.frame.maximumRows.name"],
                        desc = L["config.frame.maximumRows.desc"],
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
                    position = {
                        name = L["config.frame.position.name"],
                        type = "group",
                        inline = true,
                        order = 3,
                        args = {
                            point = {
                                name = L["config.frame.position.point.name"],
                                desc = L["config.frame.position.point.desc"],
                                type = "select",
                                values = function ()
                                    local buf = {}
                                    for _, point in ipairs(self.AnchorPoints) do
                                        buf[point] = L["config.frame.position.pointValue."..point]
                                    end
                                    return buf
                                end,
                                style = "dropdown",
                                order = 1,
                                set = function (_, value)
                                    self.db.profile.mainFrameAnchor.point = value
                                    self.Frame:Reposition()
                                end,
                                get = function () return self.db.profile.mainFrameAnchor.point end
                            },
                            relativeFrame = {
                                name = L["config.frame.position.relativeFrame.name"],
                                desc = L["config.frame.position.relativeFrame.desc"],
                                type = "input",
                                order = 2,
                                set = function (_, value)
                                    self.db.profile.mainFrameAnchor.relativeFrame = value ~= "" and value or nil
                                    self.Frame:Reposition()
                                end,
                                get = function () return self.db.profile.mainFrameAnchor.relativeFrame end
                            },
                            relativePoint = {
                                name = L["config.frame.position.relativePoint.name"],
                                desc = L["config.frame.position.relativePoint.desc"],
                                type = "select",
                                values = function ()
                                    local buf = {}
                                    for _, point in ipairs(self.AnchorPoints) do
                                        buf[point] = L["config.frame.position.pointValue."..point]
                                    end
                                    return buf
                                end,
                                style = "dropdown",
                                order = 1,
                                set = function (_, value)
                                    self.db.profile.mainFrameAnchor.relativePoint = value
                                    self.Frame:Reposition()
                                end,
                                get = function () return self.db.profile.mainFrameAnchor.relativePoint end
                            },
                            x = {
                                name = L["config.frame.position.x.name"],
                                desc = L["config.frame.position.x.desc"],
                                type = "range",
                                softMin = -250,
                                softMax = 250,
                                order = 4,
                                set = function (_, value)
                                    self.db.profile.mainFrameAnchor.x = value
                                    self.Frame:Reposition()
                                end,
                                get = function () return self.db.profile.mainFrameAnchor.x end
                            },
                            y = {
                                name = L["config.frame.position.y.name"],
                                desc = L["config.frame.position.y.desc"],
                                type = "range",
                                softMin = -250,
                                softMax = 250,
                                order = 5,
                                set = function (_, value)
                                    self.db.profile.mainFrameAnchor.y = value
                                    self.Frame:Reposition()
                                end,
                                get = function () return self.db.profile.mainFrameAnchor.y end
                            },
                            resetPosition = {
                                name = L["config.frame.position.resetPosition.name"],
                                desc = L["config.frame.position.resetPosition.desc"],
                                type = "execute",
                                func = function ()
                                    self.db.profile.mainFrameAnchor.point = "CENTER"
                                    self.db.profile.mainFrameAnchor.relativeFrame = nil
                                    self.db.profile.mainFrameAnchor.relativePoint = "CENTER"
                                    self.db.profile.mainFrameAnchor.x = 0
                                    self.db.profile.mainFrameAnchor.y = 0
                                    self.Frame:Reposition()
                                end
                            }
                        }
                    }
                }
            },
            units = {
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
                                    self.db.profile.unitWidth = value
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.unitWidth end
                            },
                            unitHeight = {
                                name = L["config.units.size.unitHeight.name"],
                                desc = L["config.units.size.unitHeight.desc"],
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
                                name = L["config.units.size.horizontalPadding.name"],
                                desc = L["config.units.size.horizontalPadding.desc"],
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
                                name = L["config.units.size.verticalPadding.name"],
                                desc = L["config.units.size.verticalPadding.desc"],
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
                        name = L["config.units.font.name"],
                        type = "group",
                        inline = true,
                        order = 2,
                        args = {
                            unitFont = {
                                name = L["config.units.font.unitFont.name"],
                                desc = L["config.units.font.unitFont.desc"],
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
                                name = L["config.units.font.unitFontSize.name"],
                                desc = L["config.units.font.unitFontSize.desc"],
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
                                name = L["config.units.font.durationFont.name"],
                                desc = L["config.units.font.durationFont.desc"],
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
                                name = L["config.units.font.durationFontSize.name"],
                                desc = L["config.units.font.durationFontSize.desc"],
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
                                    self.db.profile.buffedColor = {...}
                                    self.Frame:Redraw()
                                end,
                                get = function () return self.db.profile.buffedColor[1], self.db.profile.buffedColor[2], self.db.profile.buffedColor[3] end
                            },
                            unbuffedColor = {
                                name = L["config.units.color.unbuffedColor.name"],
                                desc = L["config.units.color.unbuffedColor.desc"],
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
                                name = L["config.units.color.unbuffedPetColor.name"],
                                desc = L["config.units.color.unbuffedPetColor.desc"],
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
                                name = L["config.units.color.outOfRangeColor.name"],
                                desc = L["config.units.color.outOfRangeColor.desc"],
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
                name = L["config.help.name"],
                type = "group",
                order = 101,
                args = {
                    spell = {
                        name = L["config.help.spell.name"],
                        type = "header",
                        order = 1
                    },
                    spellDesc = {
                        name = L["config.help.spellDesc.name"],
                        type = "description",
                        order = 2
                    },
                    buttons = {
                        name = L["config.help.buttons.name"],
                        type = "header",
                        order = 3
                    },
                    buttonsDesc = {
                        name = L["config.help.buttonsDesc.name"],
                        type = "description",
                        order = 4
                    },
                    combat = {
                        name = L["config.help.combat.name"],
                        type = "header",
                        order = 5
                    },
                    combatDesc = {
                        name = L["config.help.combatDesc.name"],
                        type = "description",
                        order = 6
                    },
                    other = {
                        name = L["config.help.other.name"],
                        type = "header",
                        order = 7
                    },
                    otherDesc = {
                        name = L["config.help.otherDesc.name"],
                        type = "description",
                        order = 8
                    }
                }
            }
        }
    }

    local function AddSpells()
        config.args.spells = {
            name = L["config.spells.name"],
            type = "group",
            order = 5,
            args = {
                useGreater = {
                    name = L["config.spells.useGreater.name"],
                    desc = L["config.spells.useGreater.desc"],
                    type = "toggle",
                    order = 1,
                    set = function (_, value) self.db.profile.spells.useGreater = value end,
                    get = function () return self.db.profile.spells.useGreater end
                },
                special = {
                    name = L["config.spells.special.name"],
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        resetPosition = {
                            name = L["config.spells.special.resetPosition.name"],
                            desc = L["config.spells.special.resetPosition.desc"],
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
                            name = L["config.spells.class.blessing.enabled.name"],
                            desc = L["config.spells.class.blessing.enabled.desc"],
                            type = "toggle",
                            order = 1,
                            set = function (_, value) self.db.profile.spells[class][blessing.key].enabled = value end,
                            get = function () return self.db.profile.spells[class][blessing.key].enabled end
                        },
                        priority = {
                            name = L["config.spells.class.blessing.priority.name"],
                            desc = L["config.spells.class.blessing.priority.desc"],
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
                            name = L["config.spells.class.blessing.up.name"],
                            desc = L["config.spells.class.blessing.up.desc"],
                            type = "execute",
                            order = 3,
                            func = function ()
                                SetPriority(class, blessing.key, self.db.profile.spells[class][blessing.key].priority - 1)
                                AddSpells()
                            end
                        },
                        down = {
                            name = L["config.spells.class.blessing.down.name"],
                            desc = L["config.spells.class.blessing.down.desc"],
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
            name = L["config.overrides.name"],
            type = "group",
            order = 6,
            args = {
                enabled = {
                    name = L["config.overrides.enabled.name"],
                    desc = L["config.overrides.enabled.desc"],
                    type = "toggle",
                    order = 1,
                    set = function (_, value) self.db.profile.overridesConfig.enabled = value end,
                    get = function () return self.db.profile.overridesConfig.enabled end
                },
                add = {
                    name = L["config.overrides.add.name"],
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        unitName = {
                            name = L["config.overrides.add.unitName.name"],
                            desc = L["config.overrides.add.unitName.desc"],
                            type = "input",
                            order = 1,
                            set = function (_, value)
                                self.db.profile.overridesConfig.name = value
                            end,
                            get = function () return self.db.profile.overridesConfig.name end
                        },
                        getTarget = {
                            name = L["config.overrides.add.getTarget.name"],
                            desc = L["config.overrides.add.getTarget.desc"],
                            type = "execute",
                            order = 2,
                            func = function () self.db.profile.overridesConfig.name = UnitName("target") or UnitName("player") end
                        },
                        add = {
                            name = L["config.overrides.add.add.name"],
                            desc = L["config.overrides.add.add.desc"],
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
                    name = L["config.overrides.special.name"],
                    type = "group",
                    inline = true,
                    order = 3,
                    args = {
                        resetPosition = {
                            name = L["config.overrides.special.resetPosition.name"],
                            desc = L["config.overrides.special.resetPosition.desc"],
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
                        name = L["config.overrides.unitName.enabled.name"],
                        desc = L["config.overrides.unitName.enabled.desc"],
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
                            name = L["config.overrides.unitName.blessing.enabled.name"],
                            desc = L["config.overrides.unitName.blessing.enabled.desc"],
                            type = "toggle",
                            order = 1,
                            set = function (_, value) self.db.profile.overrides[name][blessing.key].enabled = value end,
                            get = function () return self.db.profile.overrides[name][blessing.key].enabled end
                        },
                        priority = {
                            name = L["config.overrides.unitName.blessing.priority.name"],
                            desc = L["config.overrides.unitName.blessing.priority.desc"],
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
                            name = L["config.overrides.unitName.blessing.up.name"],
                            desc = L["config.overrides.unitName.blessing.up.desc"],
                            type = "execute",
                            order = 3,
                            func = function ()
                                SetPriority(name, blessing.key, self.db.profile.overrides[name][blessing.key].priority - 1)
                                AddOverrides()
                            end
                        },
                        down = {
                            name = L["config.overrides.unitName.blessing.down.name"],
                            desc = L["config.overrides.unitName.blessing.down.desc"],
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
                name = L["config.overrides.unitName.remove.name"],
                desc = L["config.overrides.unitName.remove.desc"],
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

    -- TODO: Move strings to enUS localization
    local function AddImportExport()
        if self.importExport == nil then
            self.importExport = {
                text = "",
                importData = nil,
                imports = {}
            }
        end

        config.args.importExport = {
            name = "Import/Export",
            type = "group",
            order = 7,
            args = {
                text = {
                    name = "Text",
                    desc = "The text that was created with the export function.",
                    type = "input",
                    order = 1,
                    set = function (_, value) self.importExport.text = value end,
                    get = function () return self.importExport.text end
                },
                import = {
                    name = "Import",
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        importAction = {
                            name = self.importExport.importData == nil and "Parse" or "Import",
                            desc = "Loads the information from the text.",
                            type = "execute",
                            order = 2,
                            func = function ()
                                if self.importExport.importData ~= nil then
                                    -- TODO: Import
                                    self.importExport.importData = nil
                                    AddImportExport()
                                elseif self.importExport.text ~= nil and self.importExport.text ~= "" then
                                    local success, data = aceSerializer:Deserialize(libDeflate:DecompressDeflate(libDeflate:DecodeForPrint(self.importExport.text)))
                                    if success and (data.frame ~= nil or data.unit ~= nil or data.spells ~= nil or data.overrides ~= nil) then
                                        self.importExport.importData = data
                                        self.importExport.imports.frame = data.frame ~= nil and true or nil
                                        self.importExport.imports.unit = data.unit ~= nil and true or nil
                                        self.importExport.imports.spells = data.spells ~= nil and true or nil
                                        self.importExport.imports.overrides = data.overrides ~= nil and true or nil
                                        AddImportExport()
                                    else
                                        print("BlessingHelper: Failed to parse text.")
                                    end
                                end
                            end
                        }
                    }
                },
                export = {
                    name = "Export",
                    type = "group",
                    inline = true,
                    order = 3,
                    args = {
                        exports = {
                            name = "Exports",
                            desc = "Select what datas will be exported.",
                            order = 1,
                            type = "multiselect",
                            values = {
                                frame = "Frame",
                                unit = "Unit",
                                spells = "Spells",
                                overrides = "Name overrides"
                            },
                            set = function (_, key, value) self.db.profile.export[key] = value end,
                            get = function (_, key) return self.db.profile.export[key] end
                        },
                        generate = {
                            name = "Generate",
                            desc = "Generates the export text.",
                            order = 2,
                            type = "execute",
                            func = function ()
                                local data = {}
                                local any = false

                                if self.db.profile.export.frame then
                                    data.frame = {
                                        maximumRows = self.db.profile.maximumRows,
                                        backgroundColor = self.db.profile.backgroundColor,
                                        self.db.profile.mainFrameAnchor
                                    }
                                    any = true
                                end

                                if self.db.profile.export.unit then
                                    data.unit = {
                                        unitWidth = self.db.profile.unitWidth,
                                        unitHeight = self.db.profile.unitHeight,
                                        horizontalPadding = self.db.profile.horizontalPadding,
                                        verticalPadding = self.db.profile.verticalPadding,
                                        unitLength = self.db.profile.unitLength,
                                        unitFont = self.db.profile.unitFont,
                                        unitFontSize = self.db.profile.unitFontSize,
                                        durationFont = self.db.profile.durationFont,
                                        durationFontSize = self.db.profile.durationFontSize,
                                        buffedColor = self.db.profile.buffedColor,
                                        unbuffedColor = self.db.profile.unbuffedColor,
                                        unbuffedPetColor = self.db.profile.unbuffedPetColor,
                                        outOfRangeColor = self.db.profile.outOfRangeColor
                                    }
                                    any = true
                                end

                                if self.db.profile.export.spells then
                                    data.spells = self.db.profile.spells
                                    any = true
                                end

                                if self.db.profile.export.overrides then
                                    data.overridesConfig = {
                                        names = self.db.profile.overridesConfig.names
                                    }
                                    data.overrides = self.db.profile.overrides
                                    any = true
                                end

                                if any then
                                    self.importExport.importData = nil
                                    self.importExport.text = libDeflate:EncodeForPrint(libDeflate:CompressDeflate(aceSerializer:Serialize(data)))
                                    AddImportExport()
                                else
                                    print("BlessingHelper: Please select at least one thing to export.")
                                end
                            end
                        }
                    }
                }
            }
        }

        if self.importExport.importData ~= nil then
            config.args.importExport.args.import.args.data = {
                name = "Data",
                type = "group",
                order = 1,
                args = {
                    imports = {
                        name = "Imports",
                        desc = "Select what datas will be imported.",
                        order = 1,
                        type = "multiselect",
                        values = function ()
                            local values = {
                                frame = "Frame",
                                unit = "Unit",
                                spells = "Spells",
                                overrides = "Name overrides"
                            }

                            -- Only show checkboxes for existing data
                            for k in pairs(values) do
                                if self.importExport.imports[k] == nil then
                                    values[k] = nil
                                end
                            end

                            return values
                        end,
                        set = function (_, key, value) self.importExport.imports[key] = value end,
                        get = function (_, key) return self.importExport.imports[key] end
                    }
                }
            }
        end
    end
    AddImportExport()

    config.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    aceConfig:RegisterOptionsTable(addon, config, { "bh", "blessinghelper" })
    aceConfigDialog:AddToBlizOptions(addon)
end

function BlessingHelper:SetupInfinitySearch()
    if InfinitySearch ~= nil then
        local aceConfigRegistry = LibStub("AceConfigRegistry-3.0")

        InfinitySearch:RegisterAddonFunction("Extras: "..addon, L["infinitySearch.options"], nil, function ()
            LibStub("AceConfigDialog-3.0"):Open(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, L["infinitySearch.lock"], nil, function ()
            self.Frame:ToggleLock()
            aceConfigRegistry:NotifyChange(addon)
        end)
        InfinitySearch:RegisterAddonFunction("Extras: "..addon, L["infinitySearch.toggle"], nil, function ()
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
                    print(L["minimap.incombat"])
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
                tooltip:AddLine(L["minimap.leftclick"])
                tooltip:AddLine(L["minimap.rightclick"])
            end
        }),
        self.db.profile.minimap
    )
end