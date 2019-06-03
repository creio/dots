-----------------------------------------------------------------------------------------------------------------------
--                                       RedFlat desktop progressbar widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Dashed horizontal progress bar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local progressbar = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		maxm        = 1,
		width       = nil,
		height      = nil,
		chunk       = { gap = 5, width = 5 },
		autoscale   = false,
		color       = { main = "#b1222b", gray = "#404040" }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.common.bar.plain") or {})
end

-- Cairo drawing functions
-----------------------------------------------------------------------------------------------------------------------

local function draw_progressbar(cr, width, height, gap, first_point, last_point, fill_color)
	cr:set_source(color(fill_color))
	for i = first_point, last_point do
		cr:rectangle((i - 1) * (width + gap), 0, width, height)
	end
	cr:fill()
end

-- Create a new progressbar widget
-- @param style.chunk Table containing dash parameters
-- @param style.color.main Main color
-- @param style.width Widget width (optional)
-- @param style.height Widget height (optional)
-- @param style.autoscale Scaling received values, true by default
-- @param style.maxm Scaling value if autoscale = false
-----------------------------------------------------------------------------------------------------------------------
function progressbar.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
	local maxm = style.maxm

	--style aliases
	local stg, stw = style.chunk.gap, style.chunk.width

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { value = 0, chunks = 1, gap = 1, cnum = 0 }

	function widg:set_value(x)
		if style.autoscale then
			if x > maxm then maxm = x end
		end

		local cx = x / maxm
		if cx > 1 then cx = 1 end

		self._data.value = cx
		local num = math.ceil(self._data.chunks * self._data.value)

		if num ~= self._data.cnum then
			self:emit_signal("widget::redraw_needed")
		end
	end

	function widg:fit(_, width, height)
		local w = style.width and math.min(style.width, width) or width
		local h = style.height and math.min(style.height, height) or height
		return w, h
	end

	-- Draw function
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)
		-- progressbar
		self._data.chunks = math.floor((width + stg) / (stw + stg))
		self._data.gap = stg + (width - (self._data.chunks - 1) * (stw + stg) - stw) / (self._data.chunks - 1)
		self._data.cnum = math.ceil(self._data.chunks * self._data.value)

		draw_progressbar(cr, stw, height, self._data.gap, 1, self._data.cnum, style.color.main)
		draw_progressbar(cr, stw, height, self._data.gap, self._data.cnum + 1, self._data.chunks, style.color.gray)
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
