require("auto-layout")

-- Trim the status line for a picker-sized pane.
--
-- Yazi's preset status line is laid out for a full window: mode, size and name
-- on the left, permissions, scroll percentage and cursor position on the right.
-- At the 40 columns the picker gets, that crams together. Two components go:
--
--   name  the file under the cursor is already the highlighted row, and the
--         directory is already in the header
--   perm  a ten-column permissions string is a quarter of the pane, and it is
--         not what you are reading a file tree for
--
-- percent stays, and not for its own sake: the position pill's left separator
-- (theme sep_right.open) is drawn to meet the percent chip behind it. With
-- percent removed the separator has nothing to blend into, so the pill renders
-- with the bar background showing through its rounded corners and reads as
-- clipped.
--
-- This is scoped to the picker by where it lives: zide points the picker pane at
-- its own YAZI_CONFIG_HOME, so a yazi started any other way is untouched.
--
-- The ids are looked up from the registered children rather than hard-coded.
-- children_remove takes the id handed out at registration, which is just a
-- counter -- a literal 3 would quietly remove whatever happened to register
-- third after an upgrade. Looking them up by name makes "removed nothing" the
-- failure mode instead of "removed the wrong thing".
--
-- Verified against yazi 26.9.1, which registers mode id=1, length id=2,
-- name id=3 on the left and perm id=4, percent id=5, position id=6 on the right.
local function trim_status(side, children, unwanted)
	if type(children) ~= "table" then
		return
	end

	local doomed = {}
	for _, child in ipairs(children) do
		if type(child) == "table" and child.id and unwanted[child[1]] then
			doomed[#doomed + 1] = child.id
		end
	end

	for _, id in ipairs(doomed) do
		Status:children_remove(id, side)
	end
end

trim_status(Status.LEFT, Status._left, { name = true })
trim_status(Status.RIGHT, Status._right, { perm = true })
