local media = LibStub("LibSharedMedia-3.0")

-- region BlessingHelperButtonTemplate events
function BlessingHelperUnitTemplate_OnLoad(self)
    BlessingHelper.CreateBackdrop(self, 0, 0, 0, 1)

    function self:Contains(blessings, blessing, own)
        for i = 1, #blessings do
            if blessings[i].name:find(blessing) ~= nil and (own == nil or own == true and blessings[i].unitCaster == "player" or own == false and blessings[i].unitCaster ~= "player") then
                return blessing, blessings[i].unitCaster == "player"
            end
        end
    end

    function self:IsPetUnit()
        return self.Unit:lower():find("pet") ~= nil
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

    function self:SetName(name)
        if BlessingHelper.db.profile.unitLength <= 0 then
            self.Name:SetText("")
            return
        end

        self.Name:SetText(name:sub(1, BlessingHelper.db.profile.unitLength))
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

        if not UnitExists(self.Unit) then
            self:SetName(self.Unit)
            self.Duration:SetText("00:00")
            self:SetBackdropColor(0, 0, 0, 1)
            return
        end

        local name = UnitName(self.Unit)
        self:SetName(name)

        if not IsSpellInRange(BlessingHelper.RangeCheckSpell, self.Unit) then
            self.LeftIcon:Hide()
            self.RightIcon:Hide()
            self.Duration:SetText("00:00")
            self:SetBackdropColor(BlessingHelper.db.profile.outOfRangeColor[1], BlessingHelper.db.profile.outOfRangeColor[2], BlessingHelper.db.profile.outOfRangeColor[3], 1)
            return
        end

        local blessings = self:Blessings()

        -- Get the current, smallest blessing that is from the player
        local smallest = nil
        for i = 1, #blessings do
            if blessings[i].unitCaster == "player" and (smallest == nil or blessings[i].expirationTime < smallest.expirationTime) then
                smallest = blessings[i]
            end
        end

        if smallest then
            -- Update display based on the current blessing
            local exp = smallest.expirationTime - GetTime()
            local m = math.floor(exp / 60)
            local s = math.floor(exp - m * 60)

            self.Duration:SetText(string.format("%02.0f:%02.0f", m, s))
            self:SetBackdropColor(BlessingHelper.db.profile.buffedColor[1], BlessingHelper.db.profile.buffedColor[2], BlessingHelper.db.profile.buffedColor[3], 1)
            self.Last = smallest.name:gsub("Greater ", "")
        else
            self.Duration:SetText("00:00")

            if self:IsPetUnit() then
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedPetColor[1], BlessingHelper.db.profile.unbuffedPetColor[2], BlessingHelper.db.profile.unbuffedPetColor[3], 1)
            else
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedColor[1], BlessingHelper.db.profile.unbuffedColor[2], BlessingHelper.db.profile.unbuffedColor[3], 1)
            end

            -- Remove the last used when someone else used it on the unit
            if self.Last and self:Contains(blessings, self.Last, false) then
                self.Last = nil
            end
        end

        if InCombatLockdown() then
            -- Show icons if the clicks are set (in case unit went out of range and came back in combat)
            if self.LastPrimary then
                self.LeftIcon:Show()
            end
            if self.LastSecondary then
                self.RightIcon:Show()
            end

            -- Do not go further if in combat
            return
        end

        local targetBlessingName, targetBlessingPriority, allowGreater

        -- Check if a name override exists
        if BlessingHelper.db.profile.overridesConfig.enabled and BlessingHelper.Contains(BlessingHelper.db.profile.overridesConfig.names, name) and BlessingHelper.db.profile.overrides[name].enabled then
            -- Get available blessings
            for _, blessing in ipairs(BlessingHelper.Blessings) do
                ---@diagnostic disable-next-line: redundant-parameter
                local usable, noMana = IsUsableSpell(blessing)
                local enabled = BlessingHelper.db.profile.overrides[name][blessing].enabled
                local priority = BlessingHelper.db.profile.overrides[name][blessing].priority
                if enabled and (usable or noMana) and not self:Contains(blessings, blessing, false) then
                    if targetBlessingPriority == nil or targetBlessingPriority > priority then
                        targetBlessingName = blessing
                        targetBlessingPriority = priority
                    end
                end
            end

            -- Disallow greater blessings for personal buffs
            allowGreater = false
        else
            -- Get the class of the unit
            local class = select(2, UnitClass(self.Unit))
            class = class:sub(1, 1)..class:sub(2):lower()

            -- Get available blessings
            for _, blessing in ipairs(BlessingHelper.Blessings) do
                ---@diagnostic disable-next-line: redundant-parameter
                local usable, noMana = IsUsableSpell(blessing)
                local enabled = BlessingHelper.db.profile.spells[class][blessing].enabled
                local priority = BlessingHelper.db.profile.spells[class][blessing].priority
                if enabled and (usable or noMana) and not self:Contains(blessings, blessing, false) then
                    if targetBlessingPriority == nil or targetBlessingPriority > priority then
                        targetBlessingName = blessing
                        targetBlessingPriority = priority
                    end
                end
            end

            allowGreater = true
        end

        -- No blessing found
        if not targetBlessingName then
            if not smallest and not self.Last then
                self:SetAttribute("spell1", "")
                self.LeftIcon:Hide()
                self.LastPrimary = nil
            end
            self:SetAttribute("spell2",  "")
            self.RightIcon:Hide()
            self.LastSecondary = nil
            return
        end

        if allowGreater and BlessingHelper.db.profile.spells.useGreater then
            ---@diagnostic disable-next-line: redundant-parameter
            local usable, noMana = IsUsableSpell("Greater "..targetBlessingName)

            if usable or noMana then
                targetBlessingName = "Greater "..targetBlessingName
            end
        end

        -- Update primary cast
        local primary = smallest and smallest.name or self.Last or targetBlessingName
        ---@diagnostic disable-next-line: redundant-parameter
        self.LeftIcon:SetTexture((select(3, GetSpellInfo(primary))))
        self:SetAttribute("spell1", primary)
        self.LeftIcon:Show()
        self.LastPrimary = primary

        -- Set the secondary cast to always be based on priority
        ---@diagnostic disable-next-line: redundant-parameter
        self.RightIcon:SetTexture((select(3, GetSpellInfo(targetBlessingName))))
        self:SetAttribute("spell2",  targetBlessingName)
        self.RightIcon:Show()
        self.LastSecondary = targetBlessingName
    end
end
-- endregion
