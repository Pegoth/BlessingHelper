local addon = ...

local function transform(L, key, value)
    if type(value) == "table" then
        for k, v in pairs(value) do
            transform(L, (key and key.."." or "")..k, v)
        end
    else
        L[key] = value
    end
end

function CreateLocale(language, default, translations)
    if translations == nil then
        translations = default
        default = nil
    end

    local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale(addon, language, default)
    if L then
        transform(L, nil, translations)
    end
end