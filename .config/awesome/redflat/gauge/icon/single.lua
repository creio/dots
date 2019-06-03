-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat indicator widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Image indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local beautiful = require("beautiful")
local wibox = require("wibox")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local gicon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = redutil.base.placeholder(),
		step        = 0.05,
		is_vertical = false,
		color       = { main = "#b1222b", icon = "#a0a0a0", urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.icon.single") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function pattern_string_v(height, value, c1, c2)
	return string.format("linear:0,%s:0,0:0,%s:%s,%s:%s,%s:1,%s", height, c1, value, c1, value, c2, c2)
end

local function pattern_string_h(width, value, c1, c2)
	return string.format("linear:0,0:%s,0:0,%s:%s,%s:%s,%s:1,%s", width, c1, value, c1, value, c2, c2)
end

-- Create a new gicon widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function gicon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
	local pattern = style.is_vertical and pattern_string_v or pattern_string_h

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = wibox.container.background(svgbox(style.icon))
	widg._data = {
		color = style.color.main,
		level = 0,
	}

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		if x > 1 then x = 1 end

		if self.widget._image then
			local level = math.floor(x / style.step) * style.step

			if level ~= self._data.level then
				self._data.level = level
				local d = style.is_vertical and self.widget._image.height or self._image.width
				self.widget:set_color(pattern(d, level, self._data.color, style.color.icon))
			end
		end
	end

	function widg:set_alert(alert)
		-- not sure about redraw after alert set
		self._data.color = alert and style.color.urgent or style.color.main
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call gicon module as function
-----------------------------------------------------------------------------------------------------------------------
function gicon.mt:__call(...)
	return gicon.new(...)
end

return setmetatable(gicon, gicon.mt)
