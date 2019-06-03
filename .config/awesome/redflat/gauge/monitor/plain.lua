-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with label and progressbar
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
local monitor = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		line       = { height = 4, y = 30 },
		font       = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_shift = 22,
		label      = "MON",
		width      = 100,
		step       = 0.05,
		color      = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.monitor.plain") or {})
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function monitor.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { color = style.color.icon, level = 0, alert = false, label = style.label }

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

	function widg:set_label(label)
		if label ~= self._data.label then
			self._data.label = label
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
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width)

		-- label
		cr:set_source(color(self._data.color))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.textcentre.horizontal(cr, { width/2, style.text_shift }, self._data.label)

		-- progressbar
		local wd = { width, width * self._data.level }
		for i = 1, 2 do
			cr:set_source(color(i > 1 and style.color.main or style.color.gray))
			cr:rectangle(0, style.line.y, wd[i], style.line.height)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function monitor.mt:__call(...)
	return monitor.new(...)
end

return setmetatable(monitor, monitor.mt)
