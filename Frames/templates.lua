local media = LibStub("LibSharedMedia-3.0")

-- region BlessingHelperButtonTemplate events
function BlessingHelperUnitTemplate_OnLoad(self)
    BlessingHelper.CreateBackdrop(self, 1, 0, 0, 1)

    function self:Redraw()
        self.Name:ClearAllPoints()
        self.Name:SetPoint("LEFT", self, "LEFT", BlessingHelperConfig.unitHeight + 2, 0)
        self.Name:SetFont(media:Fetch("font", BlessingHelperConfig.unitFont), BlessingHelperConfig.unitFontSize)
        self.Duration:SetFont(media:Fetch("font", BlessingHelperConfig.durationFont), BlessingHelperConfig.durationFontSize)
        self.Name:SetText(self.Unit or "unknown")
        self.Duration:SetText("00:00")
    end

    self:Redraw()
end
-- endregion
