-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat indicator widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Double mage indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string
local math = math

local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dubgicon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon1       = redutil.base.placeholder(),
		icon2       = redutil.base.placeholder(),
		igap        = 8,
		step        = 0.05,
		is_vertical = false,
		color       = { main = "#b1222b", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.icon.double") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function pattern_string_v(height, value, c1, c2)
	return string.format("linear:0,%s:0,0:0,%s:%s,%s:%s,%s:1,%s", height, c1, value, c1, value, c2, c2)
end

local function pattern_string_h(width, value, c1, c2)
	return string.format("linear:0,0:%s,0:0,%s:%s,%s:%s,%s:1,%s", width, c1, value, c1, value, c2, c2)
end

-- Create a new dubgicon widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function dubgicon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
	local pattern = style.is_vertical and pattern_string_v or pattern_string_h

	-- Create widget
	--------------------------------------------------------------------------------
	local fixed = wibox.layout.fixed.horizontal()
	local layout = wibox.container.constraint(fixed, "exact", style.width)
	layout._icon1 = svgbox(style.icon1)
	layout._icon2 = svgbox(style.icon2)
	layout._data = { level = { 0, 0 }}
	fixed:add(wibox.container.margin(layout._icon1, 0, style.igap, 0, 0))
	fixed:add(layout._icon2)

	-- User functions
	------------------------------------------------------------
	function layout:set_value(value)
		local level = {
			math.floor((value[1] < 1 and value[1] or 1) / style.step) * style.step,
			math.floor((value[2] < 1 and value[2] or 1) / style.step) * style.step
		}

		for i, widg in ipairs({ self._icon1, self._icon2 }) do
			if widg._image and level[i] ~= layout._data.level[i] then
				layout._data.level[i] = level[i]

				local d = style.is_vertical and widg._image.height or widg._image.width
				widg:set_color(pattern(d, level[i], style.color.main, style.color.icon))
			end
		end
	end

	--------------------------------------------------------------------------------
	return layout
end

-- Config metatable to call dubgicon module as function
-----------------------------------------------------------------------------------------------------------------------
function dubgicon.mt:__call(...)
	return dubgicon.new(...)
end

return setmetatable(dubgicon, dubgicon.mt)
