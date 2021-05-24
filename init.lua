-- Setup globals
BlessingHelper = {}

-- Initialize config
BlessingHelperConfig = {}

local function setDefault(name, value)
    if BlessingHelperConfig[name] == nil then
        BlessingHelperConfig[name] = value
    end
end

setDefault("unitFont", "PT Sans Narrow")
setDefault("durationFont", "PT Sans Narrow")
setDefault("unitFontSize", 12)
setDefault("durationFontSize", 12)
setDefault("unitWidth", 100)
setDefault("unitHeight", 20)
setDefault("horizontalPadding", 1)
setDefault("verticalPadding", 1)
setDefault("backgroundColor", {0, 0, 0, 0.5})
setDefault("isLocked", false)


-- Limit name length?