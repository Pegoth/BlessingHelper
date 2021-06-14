local _, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

addon.Config.args.help = {
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