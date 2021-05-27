local addon = ...
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale(addon, "enUS", true)

if L then
    L["minimap.incombat"] = "\124cffffff00"..addon.."\124r: Cannot show settings or toggle frame in combat."
    L["minimap.leftclick"] = "\124cffffffffLeft click:\124r Toggle addon"
    L["minimap.rightclick"] = "\124cffffffffRight click:\124r Show settings"
    L["infinitySearch.options"] = "Options"
    L["infinitySearch.lock"] = "Lock"
    L["infinitySearch.toggle"] = "Toggle"
end