local media = LibStub("LibSharedMedia-3.0")

-- region BlessingHelperButtonTemplate events
function BlessingHelperUnitTemplate_OnLoad(self)
    BlessingHelper.CreateBackdrop(self, 0, 0, 0, 1)

    function self:Blessings(own)
        local buf = {}

        local i = 1
        local name, icon, _, _, duration, expirationTime, unitCaster = UnitBuff(self.Unit, i)
        while name do
            if name:find("Blessing of ") ~= nil then
                if own and unitCaster == "player" or not own and unitCaster ~= "player" then
                    table.insert(buf, {
                        name = name,
                        icon = icon,
                        duration = duration,
                        expirationTime = expirationTime,
                        unitCaster = unitCaster
                    })
                end
            end
            i = i + 1
            name, icon, _, _, duration, expirationTime, unitCaster = UnitBuff(self.Unit, i)
        end

        return buf
    end

    function self:Redraw()
        self.Name:ClearAllPoints()
        self.Name:SetPoint("LEFT", self, "LEFT", BlessingHelperConfig.unitHeight + 2, 0)
        self.Name:SetFont(media:Fetch("font", BlessingHelperConfig.unitFont), BlessingHelperConfig.unitFontSize)
        self.Duration:SetFont(media:Fetch("font", BlessingHelperConfig.durationFont), BlessingHelperConfig.durationFontSize)
    end

    self:Redraw()
end

function BlessingHelperUnitTemplate_OnUpdate(self, elapsed)
    -- Check for combat lockdown

    self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
    if self.TimeSinceLastUpdate > 0.1 then
        self.TimeSinceLastUpdate = 0

        if not UnitExists(self.Unit) then
            self.Icon:Hide()
            self.Name:SetText(self.Unit or "unknown")
            self.Duration:SetText("00:00")
            self:SetBackdropColor(0, 0, 0, 1)
            return
        end

        self.Name:SetText(UnitName(self.Unit))

        if not IsSpellInRange("Blessing of Wisdom", self.Unit) then
            self.Icon:Hide()
            self.Duration:SetText("00:00")
            self:SetBackdropColor(BlessingHelperConfig.outOfRangeColor[1], BlessingHelperConfig.outOfRangeColor[2], BlessingHelperConfig.outOfRangeColor[3], 1)
            return
        end

        local blessings = self:Blessings(true)
        if #blessings == 0 then
            -- TODO: Decide what to cast, for now leave it to cast the last used
            self.Duration:SetText("00:00")
            self:SetBackdropColor(BlessingHelperConfig.unbuffedColor[1], BlessingHelperConfig.unbuffedColor[2], BlessingHelperConfig.unbuffedColor[3], 1)
            return
        end

        local smallest = nil
        for i = 1, #blessings do
            if smallest == nil or blessings[i].expirationTime < smallest.expirationTime then
                smallest = blessings[i]
            end
        end

        local exp = smallest.expirationTime - GetTime()
        local m = math.floor(exp / 60)
        local s = exp - m * 60

        self:SetAttribute("spell", smallest.name)
        self.Icon:Show()
        self.Icon:SetTexture(smallest.icon)
        self.Duration:SetText(string.format("%02.0f:%02.0f", m, s == 60 and 0 or s))
        self:SetBackdropColor(BlessingHelperConfig.buffedColor[1], BlessingHelperConfig.buffedColor[2], BlessingHelperConfig.buffedColor[3], 1)
    end
end
-- endregion
