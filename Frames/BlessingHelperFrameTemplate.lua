local addon = ...

-- region BlessingHelperFrame events
function BlessingHelperFrameTemplate_OnEvent(self)
    self:Redraw()
end

function BlessingHelperFrameTemplate_OnLoad(self)
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_PET")

    self.Background:SetTexture("Interface\\Addons\\"..addon.."\\Textures\\Background")
    self.Background:ClearAllPoints()
    self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

    self.IsMoving = false

    function self:ToggleLock()
        self:SetLock(not BlessingHelper.db.profile.isLocked)
        self:Redraw()
    end

    function self:SetLock(locked)
        BlessingHelper.db.profile.isLocked = locked

        if BlessingHelper.db.profile.isLocked then
            self:EnableMouse(false)
        else
            self:EnableMouse(true)
        end

        self:Redraw()
    end

    function self:Redraw()
        if InCombatLockdown() then return end

        local x = BlessingHelper.db.profile.horizontalPadding * 2
        local y = BlessingHelper.db.profile.verticalPadding * 2
        local visibleCount = 0
        for _, f in ipairs(self.Units) do
            if not UnitExists(f.Unit) then
                f:Hide()
            else
                visibleCount = visibleCount + 1
                f:Show()
                f:SetWidth(BlessingHelper.db.profile.unitWidth)
                f:SetHeight(BlessingHelper.db.profile.unitHeight)
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
                f:Redraw()

                y = y + BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding
                if visibleCount % BlessingHelper.db.profile.maximumRows == 0 then
                    x = x + BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding
                    y = BlessingHelper.db.profile.verticalPadding * 2
                end
            end
        end

        self.Background:SetColorTexture(BlessingHelper.db.profile.backgroundColor[1], BlessingHelper.db.profile.backgroundColor[2], BlessingHelper.db.profile.backgroundColor[3], BlessingHelper.db.profile.backgroundColor[4])
        self:SetWidth(BlessingHelper.db.profile.horizontalPadding * 2 + (BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding) * math.ceil((BlessingHelper.db.profile.isLocked and visibleCount or BlessingHelper.NumUnitIds) / BlessingHelper.db.profile.maximumRows))
        self:SetHeight(BlessingHelper.db.profile.verticalPadding * 2 + (BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding) * (BlessingHelper.db.profile.isLocked and (math.min(visibleCount, BlessingHelper.db.profile.maximumRows)) or BlessingHelper.db.profile.maximumRows))
        self.Background:SetWidth(self:GetWidth())
        self.Background:SetHeight(self:GetHeight())
    end

    -- Create the units
    self.Units = {}

    for _, unit in ipairs(BlessingHelper.UnitIds) do
        for i = 1, unit.max or 1 do
            local f = CreateFrame("button", nil, self, "BlessingHelperUnitTemplate")
            f.Unit = unit.id..(unit.max and i or "")
            f:SetAttribute("unit", f.Unit)
            RegisterUnitWatch(f)
            table.insert(self.Units, f)
        end
    end

    self:Redraw()
end

function BlessingHelperFrameTemplate_OnMouseDown(self, button)
    if button == "LeftButton" then
        if not BlessingHelper.db.profile.isLocked then
            self:StartMoving()
            self.IsMoving = true
        end
    end
end

function BlessingHelperFrameTemplate_OnMouseUp(self)
    if self.IsMoving then
        self:StopMovingOrSizing()
        self.IsMoving = false

        BlessingHelper.db.profile.mainFrameAnchor.point, _, BlessingHelper.db.profile.mainFrameAnchor.relativePoint, BlessingHelper.db.profile.mainFrameAnchor.x, BlessingHelper.db.profile.mainFrameAnchor.y = self:GetPoint(1)
    end
end
-- endregion