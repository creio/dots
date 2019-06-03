-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with circle indicator
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
local cirmon = { mt = {} }
local TPI = math.pi * 2

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width        = nil,
		line_width   = 4,
		radius       = 14,
		iradius      = 6,
		step         = 0.02,
		color        = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.monitor.circle") or {})
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function cirmon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
	local cs = -TPI / 4

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { color = style.color.icon, level = 0, alert = false }

	if style.width then widg:set_forced_width(style.width) end

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		local value = x < 1 and x or 1
		local level = math.floor(value / style.step) * style.step

		if level ~= self._data.level then
			self._data.level = level
			self:emit_signal("widget::redraw_needed")
		end
	end

	function widg:set_alert(alert)
		if alert ~= self._data.alert then
			self._data.alert = alert
			self._data.color = alert and style.color.main or style.color.icon
			self:emit_signal("widget::redraw_needed")
		end
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		local size = math.min(width, height)
		return size, size
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)

		-- center circle
		cr:set_source(color(self._data.color))
		cr:arc(width / 2, height / 2, style.iradius, 0, TPI)
		cr:fill()

		-- progress circle
		cr:set_line_width(style.line_width)
		local cd = { TPI, TPI * self._data.level }
		for i = 1, 2 do
			cr:set_source(color(i > 1 and style.color.main or style.color.gray))
			cr:arc(width / 2, height / 2, style.radius, cs, cs + cd[i])
			cr:stroke()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function cirmon.mt:__call(...)
	return cirmon.new(...)
end

return setmetatable(cirmon, cirmon.mt)
