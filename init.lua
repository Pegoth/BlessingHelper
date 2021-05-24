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
        "Blessing of Sanctuary",
        "Blessing of Salvation",
        "Blessing of Light"
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
    useGreater = true
})

-- Limit name length?