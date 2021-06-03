local media = LibStub("LibSharedMedia-3.0")

-- region BlessingHelperButtonTemplate events
function BlessingHelperUnitTemplate_OnLoad(self)
    BlessingHelper.CreateBackdrop(self, 0, 0, 0, 1)

    function self:IsPetUnit()
        return self.Unit:lower():find("pet") ~= nil
    end
    function self:Blessings(own)
        local buf = {}

        local i = 1
        local name, _, _, _, duration, expirationTime, unitCaster = UnitBuff(self.Unit, i)
        while name do
            local blessing = BlessingHelper:IsBlessing(name)
            if blessing then
                if own == nil or own == true and unitCaster == "player" or own == false and unitCaster ~= "player" then
                    local copy = BlessingHelper.Blessing:Copy(blessing)
                    copy.isGreater = copy.greater.name == name
                    copy.duration = duration
                    copy.expirationTime = expirationTime
                    copy.unitCaster = unitCaster
                    table.insert(buf, copy)
                end
            end
            i = i + 1
            name, _, _, _, duration, expirationTime, unitCaster = UnitBuff(self.Unit, i)
        end

        return buf
    end
    function self:Redraw()
        self.LeftIcon:SetWidth(BlessingHelper.db.profile.unitHeight / 2)
        self.LeftIcon:SetHeight(BlessingHelper.db.profile.unitHeight)
        self.RightIcon:ClearAllPoints()
        self.RightIcon:SetPoint("LEFT", self, "LEFT", BlessingHelper.db.profile.unitHeight / 2, 0)
        self.RightIcon:SetWidth(BlessingHelper.db.profile.unitHeight / 2)
        self.RightIcon:SetHeight(BlessingHelper.db.profile.unitHeight)
        self.Name:ClearAllPoints()
        self.Name:SetPoint("LEFT", self, "LEFT", BlessingHelper.db.profile.unitHeight + 2, 0)
        self.Name:SetFont(media:Fetch("font", BlessingHelper.db.profile.unitFont), BlessingHelper.db.profile.unitFontSize)
        self.Duration:SetFont(media:Fetch("font", BlessingHelper.db.profile.durationFont), BlessingHelper.db.profile.durationFontSize)
    end

    self:Redraw()
end

function BlessingHelperUnitTemplate_OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed
    if self.TimeSinceLastUpdate > 0.1 then
        self.TimeSinceLastUpdate = 0

        -- Update unit name
        local name = UnitName(self.Unit) or self.Unit
        if BlessingHelper.db.profile.unitLength <= 0 then
            self.Name:SetText("")
        else
            self.Name:SetText(name:sub(1, BlessingHelper.db.profile.unitLength))
        end

        -- Do nothing special if unit does not exists
        if not UnitExists(self.Unit) then
            self.Duration:SetText("00:00")
            self:SetBackdropColor(0, 0, 0, 1)
            return
        end

        -- Do nothing special if not in range
        if not BlessingHelper.RangeCheckSpell:IsInRange(self.Unit) then
            self.LeftIcon:Hide()
            self.RightIcon:Hide()
            self.Duration:SetText("00:00")
            self:SetBackdropColor(BlessingHelper.db.profile.outOfRangeColor[1], BlessingHelper.db.profile.outOfRangeColor[2], BlessingHelper.db.profile.outOfRangeColor[3], 1)
            return
        end

        -- Get all blessings currently on the unit
        local currentBlessings = self:Blessings()

        -- Get the current, smallest blessing that is from the player
        local currentBlessing = nil
        for i = 1, #currentBlessings do
            if currentBlessings[i].unitCaster == "player" and (currentBlessing == nil or currentBlessings[i].expirationTime < currentBlessing.expirationTime) then
                currentBlessing = currentBlessings[i]
            end
        end

        if currentBlessing then
            -- Update display based on the current blessing
            local exp = currentBlessing.expirationTime - GetTime()
            local m = math.floor(exp / 60)
            local s = math.floor(exp - m * 60)

            self.Duration:SetText(string.format("%02.0f:%02.0f", m, s))
            self:SetBackdropColor(BlessingHelper.db.profile.buffedColor[1], BlessingHelper.db.profile.buffedColor[2], BlessingHelper.db.profile.buffedColor[3], 1)
            self.Last = currentBlessing
        else
            self.Duration:SetText("00:00")

            if self:IsPetUnit() then
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedPetColor[1], BlessingHelper.db.profile.unbuffedPetColor[2], BlessingHelper.db.profile.unbuffedPetColor[3], 1)
            else
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedColor[1], BlessingHelper.db.profile.unbuffedColor[2], BlessingHelper.db.profile.unbuffedColor[3], 1)
            end

            -- Remove the last used when someone else used it on the unit or unit changed (joined another party/party member changed)
            if self.Last and (self.Name:GetText() ~= name or self.Last:Contains(currentBlessings, true)) then
                self.Last = nil
            end
        end

        if InCombatLockdown() then
            -- Show icons if the clicks are set (in case unit went out of range and came back in combat)
            if self.HasPrimary then
                self.LeftIcon:Show()
            end
            if self.HasSecondary then
                self.RightIcon:Show()
            end

            -- Do not go further if in combat
            return
        end

        local targetBlessing, targetBlessingPriority

        -- Check if a name override exists
        if BlessingHelper.db.profile.overridesConfig.enabled and BlessingHelper.Contains(BlessingHelper.db.profile.overridesConfig.names, name) and BlessingHelper.db.profile.overrides[name].enabled then
            -- Get available blessings
            for _, blessing in ipairs(BlessingHelper.Blessings) do
                local enabled = BlessingHelper.db.profile.overrides[name][blessing.key].enabled
                local priority = BlessingHelper.db.profile.overrides[name][blessing.key].priority
                if enabled and blessing:IsUsable() and not blessing:Contains(currentBlessings, false) then
                    if targetBlessingPriority == nil or targetBlessingPriority > priority then
                        targetBlessing = BlessingHelper.Blessing:Copy(blessing)
                        targetBlessingPriority = priority
                    end
                end
            end

            -- Disallow greater blessings for personal buffs
            if targetBlessing then
                targetBlessing.isGreater = false
            end
        else
            -- Get the class of the unit
            local class = select(2, UnitClass(self.Unit))

            -- Get available blessings
            for _, blessing in ipairs(BlessingHelper.Blessings) do
                local enabled = BlessingHelper.db.profile.spells[class][blessing.key].enabled
                local priority = BlessingHelper.db.profile.spells[class][blessing.key].priority
                if enabled and blessing:IsUsable() and not blessing:Contains(currentBlessings, false) then
                    if targetBlessingPriority == nil or targetBlessingPriority > priority then
                        targetBlessing = BlessingHelper.Blessing:Copy(blessing)
                        targetBlessingPriority = priority
                    end
                end
            end

            if targetBlessing then
                targetBlessing.isGreater = BlessingHelper.db.profile.spells.useGreater
            end
        end

        -- No blessing found
        if not targetBlessing then
            if not currentBlessing and not self.Last then
                self:SetAttribute("spell1", "")
                self.LeftIcon:Hide()
                self.HasPrimary = nil
            end
            self:SetAttribute("spell2",  "")
            self.RightIcon:Hide()
            self.HasSecondary = nil
            return
        end

        -- Update primary cast
        local primary = (currentBlessing or self.Last or targetBlessing):Spell()
        self.LeftIcon:Show()
        self.LeftIcon:SetTexture(primary.icon)
        self:SetAttribute("spell1", primary.name)
        self.HasPrimary = true

        -- Set the secondary cast to always be based on priority
        local secondary = targetBlessing:Spell()
        self.RightIcon:Show()
        self.RightIcon:SetTexture(secondary.icon)
        self:SetAttribute("spell2", secondary.name)
        self.HasSecondary = true
    end
end
-- endregion
