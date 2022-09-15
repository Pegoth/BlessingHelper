local addon = ...

-- region BlessingHelperFrame events
function BlessingHelperFrameTemplate_OnLoad(self)
    ---Toggles the lock state of the frame.
    function self:ToggleLock()
        self:SetLock(not BlessingHelper.db.profile.isLocked)
    end

    ---Sets the lock state of the frame to the given value and saves it to the db.
    ---@param locked boolean Whether the frame is locked or not.
    function self:SetLock(locked)
        BlessingHelper.db.profile.isLocked = locked

        if locked then
            self:EnableMouse(false)
        else
            self:EnableMouse(true)
        end

        self:Reposition()
        self:Redraw()
    end

    ---Sets the visibility of the frame and saves it to the db.
    ---@param visible boolean Whether the frame is visible or not.
    function self:SetVisibility(visible)
        BlessingHelper.db.profile.enabled = visible

        if visible then
            self:Show()
            self:Reposition()
            self:Redraw()
        else
            self:Hide()
        end
    end

    ---Repositions and redraws the units and the frame. Will do nothing if in combat.
    function self:Redraw()
        if InCombatLockdown() then return end

        local x = BlessingHelper.db.profile.horizontalPadding
        local y = BlessingHelper.db.profile.verticalPadding

        local function next(counter)
            y = y + BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding
            if counter % BlessingHelper.db.profile.maximumRows == 0 then
                x = x + BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding
                y = BlessingHelper.db.profile.verticalPadding
            end
        end

        local function moveAndSize(f)
            f:SetWidth(BlessingHelper.db.profile.unitWidth)
            f:SetHeight(BlessingHelper.db.profile.unitHeight)
            f:ClearAllPoints()
            local point = BlessingHelper.db.profile.growth == "topLeftToDown" and "TOPLEFT" or
                          BlessingHelper.db.profile.growth == "bottomLeftToUp" and "BOTTOMLEFT" or
                          BlessingHelper.db.profile.growth == "topRightToDown" and "TOPRIGHT" or
                          BlessingHelper.db.profile.growth == "bottomRightToUp" and "BOTTOMRIGHT"
            f:SetPoint(
                point,
                self,
                point,
                (BlessingHelper.db.profile.growth == "topLeftToDown" and 1 or
                BlessingHelper.db.profile.growth == "bottomLeftToUp" and 1 or
                BlessingHelper.db.profile.growth == "topRightToDown" and -1 or
                BlessingHelper.db.profile.growth == "bottomRightToUp" and -1) * x,
                (BlessingHelper.db.profile.growth == "topLeftToDown" and -1 or
                BlessingHelper.db.profile.growth == "bottomLeftToUp" and 1 or
                BlessingHelper.db.profile.growth == "topRightToDown" and -1 or
                BlessingHelper.db.profile.growth == "bottomRightToUp" and 1) * y
            )
            f:Redraw()
        end

        -- Go through all units and order visibles first
        local visibleCount = 0
        local hiddens = {}
        for _, f in ipairs(self.Units) do
            if f:IsActive() then
                visibleCount = visibleCount + 1
                moveAndSize(f)
                next(visibleCount)
            else
                table.insert(hiddens, f)
            end
        end

        -- Order by pets first, they get dismissed and summoned mid-combat, then if in raid pet/player last, then by weight
        local isInRaid = IsInRaid()
        table.sort(hiddens, function (a, b)
            local apet = a:IsPetUnit()
            local bpet = b:IsPetUnit()

            if isInRaid then
                local araid = a:IsRaidUnit()
                local braid = b:IsRaidUnit()

                if araid and not braid then
                    return true
                elseif not araid and braid then
                    return false
                end
            end

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

        if BlessingHelper.db.profile.showAllUnits then
            visibleCount = invisibleCount
        end

        self.Background:SetColorTexture(BlessingHelper.db.profile.backgroundColor[1], BlessingHelper.db.profile.backgroundColor[2], BlessingHelper.db.profile.backgroundColor[3], BlessingHelper.db.profile.backgroundColor[4])
        self:SetWidth(BlessingHelper.db.profile.horizontalPadding + (BlessingHelper.db.profile.unitWidth + BlessingHelper.db.profile.horizontalPadding) * math.ceil(visibleCount / BlessingHelper.db.profile.maximumRows))
        self:SetHeight(BlessingHelper.db.profile.verticalPadding + (BlessingHelper.db.profile.unitHeight + BlessingHelper.db.profile.verticalPadding) * math.min(visibleCount, BlessingHelper.db.profile.maximumRows))
    end

    ---Repositions the frame based on the position settings in the db.
    function self:Reposition()
        if InCombatLockdown() or BlessingHelper.db.profile.mainFrameAnchor.relativeFrame ~= nil and _G[BlessingHelper.db.profile.mainFrameAnchor.relativeFrame] == nil then
            return
        end

        self:ClearAllPoints()
        self:SetPoint(
            BlessingHelper.db.profile.mainFrameAnchor.point,
            BlessingHelper.db.profile.mainFrameAnchor.relativeFrame,
            BlessingHelper.db.profile.mainFrameAnchor.relativePoint,
            BlessingHelper.db.profile.mainFrameAnchor.x,
            BlessingHelper.db.profile.mainFrameAnchor.y
        )
    end

    --Calls Redraw and Reposition after a short delay.
    function self:DelayedUpdate()
        C_Timer.After(0.1, function()
            self:Reposition()
            self:Redraw()
        end)
    end

    if BlessingHelper.db.profile.isLocked then
        self:EnableMouse(false)
    else
        self:EnableMouse(true)
    end

    self.Background:SetTexture("Interface\\Addons\\"..addon.."\\Textures\\Background")

    ---Whether the frame is currently being moved or not.
    self.IsMoving = false

    ---The unit frame buttons for each possible units in display priority order.
    self.Units = {}

    -- Create unit frames
    local weight = 1
    for _, unit in ipairs(BlessingHelper.UnitIds) do
        for i = 1, unit.max or 1 do
            local f = CreateFrame("button", nil, self, "BlessingHelperUnitTemplate")
            f.Weight = weight
            f.Unit = unit.id..(unit.max and i or "")
            f:SetAttribute("unit", f.Unit)
            f:UpdateUnitWatch()

            table.insert(self.Units, f)
            weight = weight + 1
        end
    end

    self:DelayedUpdate()

    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGIN")

    BlessingHelper.db.RegisterCallback(BlessingHelper, "OnProfileChanged", function()
        for _, f in ipairs(self.Units) do
            f:UpdateUnitWatch()
        end

        self:DelayedUpdate()
    end)
    BlessingHelper.db.RegisterCallback(BlessingHelper, "OnProfileReset", function()
        for _, f in ipairs(self.Units) do
            f:UpdateUnitWatch()
        end

        self:DelayedUpdate()
    end)
end

function BlessingHelperFrameTemplate_OnEvent(self)
    self:DelayedUpdate()
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