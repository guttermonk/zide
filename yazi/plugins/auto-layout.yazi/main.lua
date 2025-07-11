--- Auto-layout plugin for yazi to change number of columns based on pane width
function Tab:layout()
    if self._area.w > 80 then
        -- Wide layout: show all three panes (parent, current, preview)
        self._chunks =
            ui.Layout():direction(ui.Layout.HORIZONTAL):constraints(
            {
                ui.Constraint.Ratio(MANAGER.ratio.parent, MANAGER.ratio.all),
                ui.Constraint.Ratio(MANAGER.ratio.current, MANAGER.ratio.all),
                ui.Constraint.Ratio(MANAGER.ratio.preview, MANAGER.ratio.all)
            }
        ):split(self._area)
    elseif self._area.w > 40 then
        -- Medium layout: show current and preview panes only
        self._chunks =
            ui.Layout():direction(ui.Layout.HORIZONTAL):constraints(
            {
                ui.Constraint.Length(0),
                ui.Constraint.Ratio(1, 2),
                ui.Constraint.Ratio(1, 2)
            }
        ):split(self._area)
    else
        -- Narrow layout: show only current pane (single column)
        self._chunks =
            ui.Layout():direction(ui.Layout.HORIZONTAL):constraints(
            {
                ui.Constraint.Length(0),
                ui.Constraint.Percentage(100),
                ui.Constraint.Length(0)
            }
        ):split(self._area)
    end
end

return {}
