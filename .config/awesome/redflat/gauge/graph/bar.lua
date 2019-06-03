-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat progressbar widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Horizontal progresspar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local progressbar = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		color = { main = "#b1222b", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.graph.bar") or {})
end

-- Create a new progressbar widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function progressbar.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { value = 0 }

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		local value = x < 1 and x or 1
		if self._data.value ~= value then
			self._data.value = value
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
		cr:set_source(color(style.color.gray))
		cr:rectangle(0, 0, width, height)
		cr:fill()
		cr:set_source(color(style.color.main))
		cr:rectangle(0, 0, self._data.value * width, height)
		cr:fill()
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call progressbar module as function
-----------------------------------------------------------------------------------------------------------------------
function progressbar.mt:__call(...)
	return progressbar.new(...)
end

return setmetatable(progressbar, progressbar.mt)
