local media = LibStub("LibSharedMedia-3.0")

-- region BlessingHelperButtonTemplate events
function BlessingHelperUnitTemplate_OnLoad(self)
    BlessingHelper.CreateBackdrop(self, 0, 0, 0, 1)

    function self:Contains(blessings, blessing, own)
        for i = 1, #blessings do
            if blessings[i].name == blessing and (own == nil or own == true and blessings[i].unitCaster == "player" or own == false and blessings[i].unitCaster ~= "player") then
                return blessing, blessings[i].unitCaster == "player"
            end
        end
    end

    function self:Blessings(own)
        local buf = {}

        local i = 1
        local name, icon, _, _, duration, expirationTime, unitCaster = UnitBuff(self.Unit, i)
        while name do
            if name:find("Blessing of ") ~= nil then
                if own == nil or own == true and unitCaster == "player" or own == false and unitCaster ~= "player" then
                    table.insert(buf, {
                        name = name,
                        icon = icon,
                        duration = duration,
                        expirationTime = expirationTime,
                        unitCaster = unitCaster:lower()
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

        local blessings = self:Blessings()

        -- Get the class of the unit
        local class = select(2, UnitClass(self.Unit))
        class = class:sub(1, 1)..class:sub(2):lower()

        -- Get available blessings
        local targetBlessingName, targetBlessingPriority
        for i, blessing in ipairs(BlessingHelper.Blessings) do
            local e, p = BlessingHelper.GetSpell(class, blessing, true, i)
            if e and not self:Contains(blessings, blessing, false) then
                if targetBlessingPriority == nil or targetBlessingPriority > p then
                    targetBlessingName = blessing
                    targetBlessingPriority = p
                end
            end
        end

        if BlessingHelperConfig.spells ~= nil then
            if BlessingHelperConfig.spells.useGreater then
                targetBlessingName = "Greater "..targetBlessingName
            end
        end

        -- Set the secondary cast to always be based on priority
        if not InCombatLockdown() then
            self:SetAttribute("spell2",  targetBlessingName)
        end

        -- Get the current, smallest blessing that is from the player
        local smallest = nil
        for i = 1, #blessings do
            if blessings[i].unitCaster == "player" and (smallest == nil or blessings[i].expirationTime < smallest.expirationTime) then
                smallest = blessings[i]
            end
        end

        if not smallest then
            if self.Last == nil and not InCombatLockdown() then
                self:SetAttribute("spell1", targetBlessingName)
            end

            self.Duration:SetText("00:00")
            self:SetBackdropColor(BlessingHelperConfig.unbuffedColor[1], BlessingHelperConfig.unbuffedColor[2], BlessingHelperConfig.unbuffedColor[3], 1)
            return
        end

        local exp = smallest.expirationTime - GetTime()
        local m = math.floor(exp / 60)
        local s = math.floor(exp - m * 60)

        if not InCombatLockdown() then
            self:SetAttribute("spell1", smallest.name)
        end
        self.Icon:Show()
        self.Icon:SetTexture(smallest.icon)
        self.Duration:SetText(string.format("%02.0f:%02.0f", m, s))
        self:SetBackdropColor(BlessingHelperConfig.buffedColor[1], BlessingHelperConfig.buffedColor[2], BlessingHelperConfig.buffedColor[3], 1)

        self.Last = smallest
    end
end
-- endregion
