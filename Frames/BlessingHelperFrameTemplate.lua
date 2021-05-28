local addon = ...

-- region BlessingHelperFrame events
function BlessingHelperFrameTemplate_OnLoad(self)
    function self:ToggleLock()
        self:SetLock(not BlessingHelper.db.profile.isLocked)
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

        local function next(counter)
            y = y + BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding
            if counter % BlessingHelper.db.profile.maximumRows == 0 then
                x = x + BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding
                y = BlessingHelper.db.profile.verticalPadding * 2
            end
        end

        local function moveAndSize(f)
            f:SetWidth(BlessingHelper.db.profile.unitWidth)
            f:SetHeight(BlessingHelper.db.profile.unitHeight)
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
            f:Redraw()
        end

        -- Go through all units and order visibles first
        local visibleCount = 0
        local hiddens = {}
        for _, f in ipairs(self.Units) do
            if not UnitExists(f.Unit) then
                f:Hide()
                table.insert(hiddens, f)
            else
                visibleCount = visibleCount + 1
                f:Show()
                moveAndSize(f)
                next(visibleCount)
            end
        end

        -- Order by weight (pets first)
        table.sort(hiddens, function (a, b)
            local apet = a.Unit:find("pet") ~= nil
            local bpet = a.Unit:find("pet") ~= nil

            if apet and not bpet then
                return true
            elseif not apet and bpet then
                return false
            else
                return a.Weight < b.Weight
            end
        end)

        -- Go through invisible units and order them
        local invisibleCount = visibleCount
        for _, f in ipairs(hiddens) do
            invisibleCount = invisibleCount + 1
            moveAndSize(f)
            next(invisibleCount)
        end

        self.Background:SetColorTexture(BlessingHelper.db.profile.backgroundColor[1], BlessingHelper.db.profile.backgroundColor[2], BlessingHelper.db.profile.backgroundColor[3], BlessingHelper.db.profile.backgroundColor[4])
        self:SetWidth(BlessingHelper.db.profile.horizontalPadding * 2 + (BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding) * math.ceil((BlessingHelper.db.profile.isLocked and visibleCount or BlessingHelper.NumUnitIds) / BlessingHelper.db.profile.maximumRows))
        self:SetHeight(BlessingHelper.db.profile.verticalPadding * 2 + (BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding) * (BlessingHelper.db.profile.isLocked and (math.min(visibleCount, BlessingHelper.db.profile.maximumRows)) or BlessingHelper.db.profile.maximumRows))
    end

    function self:Reposition()
        self:ClearAllPoints()
        self:SetPoint(
            BlessingHelper.db.profile.mainFrameAnchor.point,
            BlessingHelper.db.profile.mainFrameAnchor.relativeFrame,
            BlessingHelper.db.profile.mainFrameAnchor.relativePoint,
            BlessingHelper.db.profile.mainFrameAnchor.x,
            BlessingHelper.db.profile.mainFrameAnchor.y
        )
    end

    if BlessingHelper.db.profile.isLocked then
        self:EnableMouse(false)
    else
        self:EnableMouse(true)
    end

    self.Background:SetTexture("Interface\\Addons\\"..addon.."\\Textures\\Background")
    self.IsMoving = false
    self.Units = {}

    -- Create unit frames
    local weight = 1
    for _, unit in ipairs(BlessingHelper.UnitIds) do
        for i = 1, unit.max or 1 do
            local f = CreateFrame("button", nil, self, "BlessingHelperUnitTemplate")
            f.Weight = weight
            f.Unit = unit.id..(unit.max and i or "")
            f:SetAttribute("unit", f.Unit)
            RegisterUnitWatch(f)
            table.insert(self.Units, f)
            weight = weight + 1
        end
    end

    self:Reposition()
    self:Redraw()

    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    BlessingHelper.db.RegisterCallback(BlessingHelper, "OnProfileChanged", function ()
        self:Reposition()
        self:Redraw()
    end)
    BlessingHelper.db.RegisterCallback(BlessingHelper, "OnProfileReset", function ()
        self:Reposition()
        self:Redraw()
    end)
end

function BlessingHelperFrameTemplate_OnEvent(self)
    self:Redraw()
end

function BlessingHelperFrameTemplate_OnMouseDown(self, button)
    if button == "LeftButton" then
        self:StartMoving()
        self.IsMoving = true
    end
end

function BlessingHelperFrameTemplate_OnMouseUp(self)
    if self.IsMoving then
        self:StopMovingOrSizing()
        self.IsMoving = false

        BlessingHelper.db.profile.mainFrameAnchor.point, _, BlessingHelper.db.profile.mainFrameAnchor.relativePoint, BlessingHelper.db.profile.mainFrameAnchor.x, BlessingHelper.db.profile.mainFrameAnchor.y = self:GetPoint(1)
        LibStub("AceConfigRegistry-3.0"):NotifyChange(addon)
    end
end
-- endregion