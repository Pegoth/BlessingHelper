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
        self.Icon:SetWidth(BlessingHelper.db.profile.unitHeight)
        self.Icon:SetHeight(BlessingHelper.db.profile.unitHeight)
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
            self.Icon:Hide()
            self:SetName(self.Unit)
            self.Duration:SetText("00:00")
            self:SetBackdropColor(0, 0, 0, 1)
            return
        end

        self:SetName(UnitName(self.Unit))

        if not IsSpellInRange(BlessingHelper.RangeCheckSpell, self.Unit) then
            self.Icon:Hide()
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

            self.Icon:Show()
            self.Icon:SetTexture(smallest.icon)
            self.Duration:SetText(string.format("%02.0f:%02.0f", m, s))
            self:SetBackdropColor(BlessingHelper.db.profile.buffedColor[1], BlessingHelper.db.profile.buffedColor[2], BlessingHelper.db.profile.buffedColor[3], 1)
        else
            self.Duration:SetText("00:00")

            if self:IsPetUnit() then
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedPetColor[1], BlessingHelper.db.profile.unbuffedPetColor[2], BlessingHelper.db.profile.unbuffedPetColor[3], 1)
            else
                self:SetBackdropColor(BlessingHelper.db.profile.unbuffedColor[1], BlessingHelper.db.profile.unbuffedColor[2], BlessingHelper.db.profile.unbuffedColor[3], 1)
            end
        end

        -- Do not go further if in combat
        if InCombatLockdown() then return end

        -- Get the class of the unit
        local class = select(2, UnitClass(self.Unit))
        class = class:sub(1, 1)..class:sub(2):lower()

        -- Get available blessings
        local targetBlessingName, targetBlessingPriority
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

        -- No blessing found
        if not targetBlessingName then
            if not smallest then
                self:SetAttribute("spell1", "")
            end
            self:SetAttribute("spell2",  "")
            return
        end

        if BlessingHelper.db.profile.spells.useGreater then
            ---@diagnostic disable-next-line: redundant-parameter
            local usable, noMana = IsUsableSpell("Greater "..targetBlessingName)

            if usable or noMana then
                targetBlessingName = "Greater "..targetBlessingName
            end
        end

        -- Set the secondary cast to always be based on priority
        self:SetAttribute("spell2",  targetBlessingName)

        -- Update primary cast
        self:SetAttribute("spell1", smallest and smallest.name or targetBlessingName)
    end
end
-- endregion
