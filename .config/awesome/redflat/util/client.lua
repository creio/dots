-- RedFlat util submodule

local awful = require("awful")
local client = { floatset = {} }

-- Functions
-----------------------------------------------------------------------------------------------------------------------
local function size_correction(c, geometry, is_restore)
	local sign = is_restore and - 1 or 1
	local bg = sign * 2 * c.border_width

	if geometry.width  then geometry.width	= geometry.width  - bg end
	if geometry.height then geometry.height = geometry.height - bg end
end

-- Client geometry correction by border width
--------------------------------------------------------------------------------
function client.fullgeometry(c, g)
	local ng

	if g then
		if g.width  and g.width  <= 1 then return end
		if g.height and g.height <= 1 then return end

		size_correction(c, g, false)
		ng = c:geometry(g)
	else
		ng = c:geometry()
	end

	size_correction(c, ng, true)

	return ng
end

-- Smart swap include floating layout
--------------------------------------------------------------------------------
function client.swap(c1, c2)
	local lay = awful.layout.get(c1.screen)
	if awful.util.table.hasitem(client.floatset, lay) then
		local g1, g2 = client.fullgeometry(c1), client.fullgeometry(c2)

		client.fullgeometry(c1, g2)
		client.fullgeometry(c2, g1)
	end

	c1:swap(c2)
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return client

