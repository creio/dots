-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with dash indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dashmon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width = 40,
		line  = { num = 5, height = 4 },
		color = { main = "#b1222b", urgent = "#00725b", gray = "#575757" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.monitor.dash") or {})
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function dashmon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { color = style.color.main, level = 0, alert = false }

	if style.width then widg:set_forced_width(style.width) end

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		local value = x < 1 and x or 1
		local level = math.ceil(style.line.num * value)

		if level ~= self._data.level then
			self._data.level = level
			self:emit_signal("widget::redraw_needed")
		end
	end

	function widg:set_alert(alert)
		if alert ~= self._data.alert then
			self._data.alert = alert
			self._data.color = alert and style.color.urgent or style.color.main
			self:emit_signal("widget::redraw_needed")
		end
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)

		local gap = (height - style.line.height * style.line.num) / (style.line.num - 1)
		local dy = style.line.height + gap

		for i = 1, style.line.num do
			cr:set_source(color(i <= self._data.level and self._data.color or style.color.gray))
			cr:rectangle(0, height - (i - 1) * dy, width, - style.line.height)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function dashmon.mt:__call(...)
	return dashmon.new(...)
end

return setmetatable(dashmon, dashmon.mt)
