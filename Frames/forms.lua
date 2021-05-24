local addon = ...

-- region BlessingHelperFrame events
function BlessingHelperFrame_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addon then
            self:Redraw()
            self:UnregisterEvent("ADDON_LOADED")
        end

        return
    end

    self:Redraw()
end

function BlessingHelperFrame_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    BlessingHelper.Frame = self
    self.Background:SetTexture("Interface\\Addons\\"..addon.."\\Textures\\Background")
    self.Background:ClearAllPoints()
    self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

    self.isMoving = false

    function self:SetLock(locked)
        BlessingHelperConfig.isLocked = locked

        if BlessingHelperConfig.isLocked then
            self:EnableMouse(false)
        else
            self:EnableMouse(true)
        end
        
        self:Redraw()
    end

    function self:ToggleLock()
        self:SetLock(not BlessingHelperConfig.isLocked)
    end

    function self:Redraw()
        -- TODO: Check for combat lockdown

        local group = IsInGroup()
        local raid = group and UnitInRaid("player") or false

        local x = BlessingHelperConfig.horizontalPadding * 2
        local y = BlessingHelperConfig.verticalPadding * 2
        local max = group and (raid and 40 or 5) or 1
        for i = 1, 40 do
            local f = self.Units[i]
            local unit = group and (raid and "raid"..i or "party"..i) or "player"

            if i > max then
                f:Hide()
            else
                f:Show()
                f.Unit = unit
                f:SetAttribute("unit", unit)
                f:SetWidth(BlessingHelperConfig.unitWidth)
                f:SetHeight(BlessingHelperConfig.unitHeight)
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
                f.Icon:SetWidth(BlessingHelperConfig.unitHeight)
                f.Icon:SetHeight(BlessingHelperConfig.unitHeight)
                f:Redraw()

                y = y + BlessingHelperConfig.unitHeight + BlessingHelperConfig.verticalPadding
                if i == 10 or i == 20 or i == 30 then
                    x = x + BlessingHelperConfig.unitWidth + BlessingHelperConfig.horizontalPadding
                    y = BlessingHelperConfig.verticalPadding * 2
                end
            end
        end

        self.Background:SetColorTexture(BlessingHelperConfig.backgroundColor[1], BlessingHelperConfig.backgroundColor[2], BlessingHelperConfig.backgroundColor[3], BlessingHelperConfig.backgroundColor[4])
        self:SetWidth(BlessingHelperConfig.horizontalPadding * 2 + (BlessingHelperConfig.unitWidth + BlessingHelperConfig.horizontalPadding) * (BlessingHelperConfig.isLocked and math.ceil(max / 10) or 4))
        self:SetHeight(BlessingHelperConfig.verticalPadding * 2 + (BlessingHelperConfig.unitHeight + BlessingHelperConfig.verticalPadding) * (BlessingHelperConfig.isLocked and (math.min(max, 10)) or 10))
        self.Background:SetWidth(self:GetWidth())
        self.Background:SetHeight(self:GetHeight())
    end

    -- Create the units
    self.Units = {}

    for i = 1, 40 do
        self.Units[i] = CreateFrame("button", nil, self, "BlessingHelperUnitTemplate")
        self.Units[i].Index = i
    end

    self:Redraw()
end

function BlessingHelperFrame_OnMouseDown(self, button)
    if button == "LeftButton" then
        if not BlessingHelperConfig.isLocked then
            self:StartMoving()
            self.isMoving = true
        end
    else
        self:ToggleLock()
    end
end

function BlessingHelperFrame_OnMouseUp(self)
    if self.isMoving then
        self:StopMovingOrSizing()
        self.isMoving = false
    end
end
-- endregion