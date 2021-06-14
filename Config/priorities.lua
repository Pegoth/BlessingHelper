local _, addon = ...
local E = addon.Engine
local L = LibStub("AceLocale-3.0"):GetLocale(addon)

if addon.Temp == nil then addon.Temp = {} end

addon.Config.args.priorities = {
    name = L["config.priorities.name"],
    type = "group",
    order = 5,
    args = {
        useGreater = {
            name = L["config.priorities.useGreater.name"],
            desc = L["config.priorities.useGreater.desc"],
            type = "toggle",
            order = 1,
            set = function (_, value) E.db.profile.priorityConfig.useGreater = value end,
            get = function () return E.db.profile.priorityConfig.useGreater end
        },
        special = {
            name = L["config.priorities.special.name"],
            type = "group",
            inline = true,
            order = 2,
            args = {
                reset = {
                    name = L["config.priorities.special.reset.name"],
                    desc = L["config.priorities.special.reset.desc"],
                    type = "execute",
                    order = 1,
                    func = function ()
                        wipe(E.db.profile.priorities)
                        wipe(E.db.profile.priorityConfig.keys)
                    end
                }
            }
        },
        add = {
            name = L["config.priorities.add.name"],
            type = "group",
            inline = true,
            order = 3,
            args = {
                type = {
                    name = L["config.priorities.add.type.name"],
                    desc = L["config.priorities.add.type.desc"],
                    type = "select",
                    values = {
                        name = L["config.priorities.add.type.values.name"],
                        class = L["config.priorities.add.type.values.class"]
                    },
                    style = "radio",
                    set = function (_, value) addon.Temp.priorityType = value end,
                    get = function () return addon.Temp.priorityType or "name" end
                },
                unitName = {
                    name = L["config.priorities.add.unitName.name"],
                    desc = L["config.priorities.add.unitName.desc"],
                    type = "input",
                    order = 1,
                    hidden = function () return addon.Temp.priorityType == "class" end,
                    set = function (_, value) addon.Temp.priorityKey = value end,
                    get = function () return addon.Temp.priorityKey end
                },
                getTargetName = {
                    name = L["config.priorities.add.getTargetName.name"],
                    desc = L["config.priorities.add.getTargetName.desc"],
                    type = "execute",
                    order = 2,
                    hidden = function () return addon.Temp.priorityType == "class" end,
                    func = function () addon.Temp.priorityKey = UnitName("target") or UnitName("player") end
                },
                unitClass = {
                    name = L["config.priorities.add.unitClass.name"],
                    desc = L["config.priorities.add.unitClass.desc"],
                    type = "select",
                    style = "dropdown",
                    values = function ()
                        local buf = {}
                        for _, class in ipairs(CLASS_SORT_ORDER) do
                            buf[class] = LOCALIZED_CLASS_NAMES_MALE[class]
                        end
                        return buf
                    end,
                    order = 1,
                    hidden = function () return addon.Temp.priorityType ~= "class" end,
                    set = function (_, value) addon.Temp.priorityKey = value end,
                    get = function () return addon.Temp.priorityKey end
                },
                getTargetClass = {
                    name = L["config.priorities.add.getTargetClass.name"],
                    desc = L["config.priorities.add.getTargetClass.desc"],
                    type = "execute",
                    order = 2,
                    hidden = function () return addon.Temp.priorityType ~= "class" end,
                    func = function () addon.Temp.priorityKey = UnitClass("target") or UnitClass("player") end
                },
                add = {
                    name = L["config.priorities.add.add.name"],
                    desc = L["config.priorities.add.add.desc"],
                    type = "execute",
                    order = 3,
                    func = function ()
                        if addon.Temp.priorityKey ~= nil and not addon.Contains(E.db.profile.priorityConfig.keys, addon.Temp.priorityKey) then
                            table.insert(E.db.profile.priorityConfig.keys, addon.Temp.priorityKey)
                        end
                        addon.Temp.priorityKey = nil
                    end
                }
            }
        }
    }
}

---Moves all priorities of blessings down/up when one blessing is moved to a specific priority
---@param priorityKey string The name of the priority.
---@param blessingKey string The key of the Blessing used in addon.Blessings.
---@param new number The new priority.
local function setPriority(priorityKey, blessingKey, new)
    if new >= 1 and new <= #addon.Blessings then
        local old = E.db.profile.priorities[priorityKey][blessingKey].priority

        if old ~= new then
        local buf = {}
            for k, v in pairs(E.db.profile.priorities[priorityKey]) do
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

            E.db.profile.priorities[priorityKey][blessingKey].priority = new
        end
    end
end

---Adds the available Blessings to the table.
---@param priorityKey string The name of the priority.
---@param order number|function The order to set for the config.
local function addBlessings(priorityKey, order)
    local name = priorityKey

    if name == "default" then
        name = L["config.priorities.default.name"]
    elseif LOCALIZED_CLASS_NAMES_MALE[name] ~= nil then
        name = LOCALIZED_CLASS_NAMES_MALE[name]
    end

    addon.Config.args.priorities.args[priorityKey] = {
        name = name,
        type = "group",
        order = order,
        args = {}
    }

    for _, blessing in ipairs(addon.Blessings) do
        addon.Config.args.priorities.args[priorityKey].args[blessing.key] = {
            name = blessing.normal.name,
            type = "group",
            order = function () return E.db.profile.priorities[priorityKey][blessing.key].priority end,
            args = {
                enabled = {
                    name = L["config.priorities.priority.blessing.enabled.name"],
                    desc = L["config.priorities.priority.blessing.enabled.desc"],
                    type = "toggle",
                    order = 1,
                    set = function (_, value) E.db.profile.priorities[priorityKey][blessing.key].enabled = value end,
                    get = function () return E.db.profile.priorities[priorityKey][blessing.key].enabled end
                },
                priority = {
                    name = L["config.priorities.priority.blessing.priority.name"],
                    desc = L["config.priorities.priority.blessing.priority.desc"],
                    type = "range",
                    step = 1,
                    min = 1,
                    max = #addon.Blessings,
                    order = 2,
                    set = function (_, value) setPriority(priorityKey, blessing.key, value) end,
                    get = function () return E.db.profile.priorities[priorityKey][blessing.key].priority end
                },
                up = {
                    name = L["config.priorities.priority.blessing.up.name"],
                    desc = L["config.priorities.priority.blessing.up.desc"],
                    type = "execute",
                    order = 3,
                    func = function () setPriority(priorityKey, blessing.key, E.db.profile.priorities[priorityKey][blessing.key].priority - 1) end
                },
                down = {
                    name = L["config.priorities.priority.blessing.down.name"],
                    desc = L["config.priorities.priority.blessing.down.desc"],
                    type = "execute",
                    order = 4,
                    func = function () setPriority(priorityKey, blessing.key, E.db.profile.priorities[priorityKey][blessing.key].priority + 1) end
                }
            }
        }
    end
end

addBlessings("default", 4)
for i, priorityKey in ipairs(E.db.profile.priorityConfig.keys) do
    addBlessings(priorityKey, 4 + i)
end