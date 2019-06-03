-- RedFlat util submodule

local awful = require("awful")

local placement = {}
local direction = { x = "width", y = "height" }

-- Functions
-----------------------------------------------------------------------------------------------------------------------
function placement.add_gap(geometry, gap)
	return {
		x = geometry.x + gap,
		y = geometry.y + gap,
		width = geometry.width - 2 * gap,
		height = geometry.height - 2 * gap
	}
end

function placement.no_offscreen(object, gap, area)
	local geometry = object:geometry()
	local border = object.border_width

	local screen_idx = object.screen or awful.screen.getbycoord(geometry.x, geometry.y)
	area = area or screen[screen_idx].workarea
	if gap then area = placement.add_gap(area, gap) end

	for coord, dim in pairs(direction) do
		if geometry[coord] + geometry[dim] + 2 * border > area[coord] + area[dim] then
			geometry[coord] = area[coord] + area[dim] - geometry[dim] - 2*border
		elseif geometry[coord] < area[coord] then
			geometry[coord] = area[coord]
		end
	end

	object:geometry(geometry)
end

local function centered_base(is_h, is_v)
	return function(object, gap, area)
		local geometry = object:geometry()
		local new_geometry = {}

		local screen_idx = object.screen or awful.screen.getbycoord(geometry.x, geometry.y)
		area = area or screen[screen_idx].geometry
		if gap then area = placement.add_gap(area, gap) end

		if is_h then new_geometry.x = area.x + (area.width - geometry.width) / 2 - object.border_width end
		if is_v then new_geometry.y = area.y + (area.height - geometry.height) / 2 - object.border_width end

		return object:geometry(new_geometry)
	end
end

placement.centered = setmetatable({}, {
	__call = function(_, ...) return centered_base(true, true)(...) end
})
placement.centered.horizontal = centered_base(true, false)
placement.centered.vertical = centered_base(false, true)


-- End
-----------------------------------------------------------------------------------------------------------------------
return placement

