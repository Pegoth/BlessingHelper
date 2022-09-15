local addon = ...

CreateLocale("enUS", true, {
    config = {
        enabled = {
            name = "Enabled",
            desc = "Whether the frame is visible or not."
        },
        isLocked = {
            name = "Locked",
            desc = "Whether the moving/resizing frame is shown or not."
        },
        showAllUnits = {
            name = "Test mode",
            desc = "When enabled even frames with non-existing units will be shown for test purposes."
        },
        frame = {
            name= "Frame settings",
            backgroundColor = {
                name = "Background color",
                desc = "The color of the background."
            },
            maximumRows = {
                name = "Maximum rows",
                desc = "The maximum amount of units to display in a column."
            },
            growth = {
                name = "Growth",
                desc = "The start position of the unit frames and the grow direction.",
                values = {
                    topLeftToDown = "Top left, grow downward",
                    topRightToDown = "Top right, grow downward",
                    bottomLeftToUp = "Bottom left, grow upward",
                    bottomRightToUp = "Bottom right, grow upward"
                }
            },
            position = {
                name = "Position",
                point = {
                    name = "Point",
                    desc = "The point of the main frame that will be anchored."
                },
                relativeFrame = {
                    name = "Relative frame",
                    desc = "The name of the frame to anchor to or empty."
                },
                relativePoint = {
                    name = "Relative point",
                    desc = "The point on the relative frame to be anchored to."
                },
                x = {
                    name = "X",
                    desc = "The position of the frame."
                },
                y = {
                    name = "Y",
                    desc = "The position of the frame."
                },
                resetPosition = {
                    name = "Reset position",
                    desc = "Resets the position of the main frame."
                },
                pointValue = {
                    TOPLEFT = "Top left",
                    TOP = "Top",
                    TOPRIGHT = "Top right",
                    RIGHT = "Right",
                    BOTTOMRIGHT = "Bottom right",
                    BOTTOM = "Bottom",
                    BOTTOMLEFT = "Bottom left",
                    LEFT = "Left",
                    CENTER = "Center"
                }
            }
        },
        units = {
            name = "Unit settings",
            size = {
                name = "Size",
                unitWidth = {
                    name = "Unit width",
                    desc = "The width of the unit."
                },
                unitHeight = {
                    name = "Unit height",
                    desc = "The height of the unit."
                },
                horizontalPadding = {
                    name = "Horizontal padding",
                    desc = "The pixels between units on the Y coord."
                },
                verticalPadding = {
                    name = "Vertical padding",
                    desc = "The pixels between units on the Y coord."
                }
            },
            font = {
                name = "Font",
                unitFont = {
                    name = "Unit font",
                    desc = "The font to use to display the unit."
                },
                unitFontSize = {
                    name = "Unit font size",
                    desc = "The size of the font that is used to display the unit."
                },
                durationFont = {
                    name = "Duration font",
                    desc = "The font to use to display the duration."
                },
                durationFontSize = {
                    name = "Duration font size",
                    desc = "The size of the font that is used to display the duration."
                }
            },
            color = {
                name = "Color",
                buffedColor = {
                    name = "Buffed color",
                    desc = "Color of units that are buffed and no action needed."
                },
                unbuffedColor = {
                    name = "Unbuffed color",
                    desc = "Color of units that are not buffed and in range."
                },
                unbuffedPetColor = {
                    name = "Unbuffed pet color",
                    desc = "Color of pet units that are not buffed and in range."
                },
                outOfRangeColor = {
                    name = "Out of range color",
                    desc = "Color of units that are out of range."
                }
            },
            other = {
                name = "Other",
                unitLength = {
                    name = "Unit length",
                    desc = "The maximum length of the unit name. Set to 0 to not display names at all."
                }
            }
        },
        spells = {
            name = "Spells",
            useGreater = {
                name = "Use Greater blessings",
                desc = "When checked will cast Greater Blessing of ... instead of Blessing of ..."
            },
            special = {
                name = "Special",
                resetPosition = {
                    name = "Reset",
                    desc = "Resets the settings of the spells/classes to their default."
                }
            },
            class = {
                blessing = {
                    enabled = {
                        name = "Enabled",
                        desc = "Whether the buff is allowed or not for this class."
                    },
                    priority = {
                        name = "Priority",
                        desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the unit."
                    },
                    up = {
                        name = "Up",
                        desc = "Moves the blessing one priority higher."
                    },
                    down = {
                        name = "Down",
                        desc = "Moves the blessing one priority lower."
                    }
                }
            }
        },
        overrides = {
            name = "Name overrides",
            enabled = {
                name = "Enabled",
                desc = "Whether the overrides are enabled or not."
            },
            add = {
                name = "Add",
                unitName = {
                    name = "Name",
                    desc = "The name of the character."
                },
                getTarget = {
                    name = "Get target",
                    desc = "Gets the name of the current target or the player if no target."
                },
                add = {
                    name = "Add",
                    desc = "Adds a new override with the current name."
                }
            },
            special = {
                name = "Special",
                resetPosition = {
                    name = "Reset",
                    desc = "Resets the settings of the overrides to their default."
                }
            },
            unitName = {
                enabled = {
                    name = "Enabled",
                    desc = "Whether the override is active or not for this name."
                },
                blessing = {
                    enabled = {
                        name = "Enabled",
                        desc = "Whether the buff is allowed or not for this name."
                    },
                    priority = {
                        name = "Priority",
                        desc = "The priority of the buff, lower number means it will be sooner selected to be cast on the unit."
                    },
                    up = {
                        name = "Up",
                        desc = "Moves the blessing one priority higher."
                    },
                    down = {
                        name = "Down",
                        desc = "Moves the blessing one priority lower."
                    }
                },
                remove = {
                    name = "Remove",
                    desc = "Removes this unit name override."
                }
            }
        },
        importExport = {
            name = "Import/Export",
            text = {
                name = "Text",
                desc = "The text that was created with the export function."
            },
            import = {
                name = "Import",
                data = {
                    name = "Data",
                    imports = {
                        name = "Imports",
                        desc = "Select what datas will be imported."
                    }
                },
                importAction = {
                    import = {
                        name = "Import",
                        desc = "Imports the selected values to the current profile.\nWARNING: It will override every selected setting!"
                    },
                    parse = {
                        name = "Parse",
                        desc = "Loads the information from the text.",
                        error = "Failed to parse text."
                    }
                }
            },
            export = {
                name = "Export",
                exports = {
                    name = "Exports",
                    desc = "\124cffffff00"..addon.."\124r: Select what datas will be exported."
                },
                generate = {
                    name = "Generate",
                    desc = "Generates the export text.",
                    error = "\124cffffff00"..addon.."\124r: Please select at least one thing to export."
                }
            },
            values = {
                frame = "Frame",
                unit = "Unit",
                spells = "Spells",
                overrides = "Name overrides"
            }
        },
        help = {
            name = "Help",
            spell = {
                name = "Blessings"
            },
            spellDesc = {
                name = "Which blessing will be cast is based on three factors (in order):\n  \124cffffff001.)\124r If the unit already has a buff from the player or one expired it will be choosen.\n  \124cffffff002.)\124r If the unit name exists in the Spell overrides (and both the Spell overrides and the specific override is enabled) that setting will be used.\n  \124cffffff003.)\124r Based on the unit class from the Spells settings."
            },
            buttons = {
                name = "Buttons"
            },
            buttonsDesc = {
                name = "There are 3 mouse button action available for each unit:\n  \124cffffff00Left click:\124r Smart cast the blessing based on the description above.\n  \124cffffff00Right click:\124r Cast the blessing based on the points \124cffffff002.\124r and \124cffffff003.\124r mentioned above (meaning it will ignore the current buff).\n  \124cffffff00Middle click:\124r Target the unit"
            },
            combat = {
                name = "Combat"
            },
            combatDesc = {
                name = "In combat the logic is suspended, meaning that left and right click will cast the last set values.\nUnits leaving party/raid will be hidden during combat, but the main frame will not be re-formatted (leaving gaps).\nUnits joining party/raid during combat will be displayed, but can be out of frame when the frame is locked and the left/right click might not work or cast wrong blessings."
            },
            other = {
                name = "Other"
            },
            otherDesc = {
                name = "The unlocked frame shows the size of maximum amount of units visible at once including pets. In any normal raid/party that size will never be reached."
            }
        }
    },
    infinitySearch = {
        options = "Options",
        lock = "Lock",
        toggle = "Toggle"
    },
    minimap = {
        incombat = "\124cffffff00"..addon.."\124r: Cannot show settings or toggle frame in combat.",
        leftclick = "\124cffffffffLeft click:\124r Toggle addon",
        rightclick = "\124cffffffffRight click:\124r Show settings"
    }
})