-- Setup globals
BlessingHelper = {
    Classes = {
        "Druid",
        "Hunter",
        "Mage",
        "Paladin",
        "Priest",
        "Rogue",
        "Shaman",
        "Warlock",
        "Warrior"
    },
    Blessings = {
        "Blessing of Kings",
        "Blessing of Wisdom",
        "Blessing of Might",
        "Blessing of Light",
        "Blessing of Salvation",
        "Blessing of Sanctuary"
    }
}

-- Initialize config
BlessingHelperConfig = {}

local function setDefault(name, value)
    if BlessingHelperConfig[name] == nil then
        BlessingHelperConfig[name] = value
    end
end

setDefault("unitFont", "PT Sans Narrow")
setDefault("durationFont", "PT Sans Narrow")
setDefault("unitFontSize", 10)
setDefault("durationFontSize", 12)
setDefault("unitWidth", 100)
setDefault("unitHeight", 20)
setDefault("horizontalPadding", 1)
setDefault("verticalPadding", 1)
setDefault("backgroundColor", {0, 0, 0, 0.5})
setDefault("buffedColor", {0, 1, 0})
setDefault("unbuffedColor", {1, 0, 0})
setDefault("outOfRangeColor", {0.1, 0.1, 0.1})
setDefault("isLocked", false)
setDefault("spells", {
    useGreater = true,
    Warrior = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Paladin = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Shaman = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Rogue = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Mage = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Druid = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
    },
    Priest = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    },
    Hunter = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
    },
    Warlock = {
        ["Blessing of Salvation"] = {
            enabled = true,
            priority = 5,
        },
        ["Blessing of Sanctuary"] = {
            enabled = true,
            priority = 6,
        },
        ["Blessing of Light"] = {
            enabled = true,
            priority = 4,
        },
        ["Blessing of Might"] = {
            enabled = true,
            priority = 3,
        },
        ["Blessing of Wisdom"] = {
            enabled = true,
            priority = 2,
        },
        ["Blessing of Kings"] = {
            enabled = true,
            priority = 1,
        },
    }
})

-- Limit name length?