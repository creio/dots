-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat dashcontrol widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Horizontal progresspar with stairs form
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
local dashcontrol = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		plain = false,
		bar   = { width = 4, num = 10 },
		color = { main = "#b1222b", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.graph.dash") or {})
end

-- Create a new dashcontrol widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function dashcontrol.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { value = 0, cnum = 0 }

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		self._data.value = x < 1 and x or 1
		local num = math.ceil(widg._data.value * style.bar.num)

		if num ~= self._data.cnum then
			self._data.cnum = num
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
		local wstep = (width - style.bar.width) / (style.bar.num - 1)
		local hstep = height / style.bar.num
		--self._data.cnum = math.ceil(widg._data.value * style.bar.num)

		for i = 1, style.bar.num do
			cr:set_source(color(i > self._data.cnum and style.color.gray or style.color.main))
			cr:rectangle((i - 1) * wstep, height, style.bar.width,  style.plain and -height or - i * hstep)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call dashcontrol module as function
-----------------------------------------------------------------------------------------------------------------------
function dashcontrol.mt:__call(...)
	return dashcontrol.new(...)
end

return setmetatable(dashcontrol, dashcontrol.mt)
