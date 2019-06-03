-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat doublemonitor widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with two progressbar and icon
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local unpack = unpack or table.unpack

local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local doublemonitor = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		line    = { width = 4, v_gap = 6, gap = 4, num = 5 },
		icon    = redutil.base.placeholder(),
		dmargin = { 10, 0, 0, 0 },
		width   = 100,
		color   = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.monitor.double") or {})
end

-- Create progressbar widget
-----------------------------------------------------------------------------------------------------------------------
local function pbar(style)

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()
	widg._data = { level = { 0, 0 }}

	-- User functions
	------------------------------------------------------------
	function widg:set_value(value)
		local level = {
			math.ceil((value[1] < 1 and value[1] or 1) / style.line.num),
			math.ceil((value[2] < 1 and value[2] or 1) / style.line.num),
		}

		if level[1] ~= self._data.level[1] or level[2] ~= self._data.level[2] then
			self._data.level[1] = level[1]
			self._data.level[2] = level[2]
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
		local wd = (width + style.line.gap) / style.line.num - style.line.gap
		local dy = (height - (2 * style.line.width + style.line.v_gap)) / 2

		for i = 1, 2 do
			for k = 1, style.line.num do
				cr:set_source(color(k <= self._data.level[i] and style.color.main or style.color.gray))
				cr:rectangle(
					(k - 1) * (wd + style.line.gap), dy + (i - 1) * (style.line.width + style.line.v_gap),
					wd, style.line.width
				)
				cr:fill()
			end
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Cunstruct a new doublemonitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function doublemonitor.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Construct layout
	--------------------------------------------------------------------------------
	local fixed = wibox.layout.fixed.horizontal()
	fixed:set_forced_width(style.width)
	local widg = pbar(style)
	local icon = svgbox(style.icon)

	icon:set_color(style.color.icon)

	fixed:add(icon)
	fixed:add(wibox.container.margin(widg, unpack(style.dmargin)))

	-- User functions
	--------------------------------------------------------------------------------
	function fixed:set_value(value)
		widg:set_value(value)
	end

	function fixed:set_alert(alert)
		icon:set_color(alert and style.color.urgent or style.color.icon)
	end

	--------------------------------------------------------------------------------
	return fixed
end

-- Config metatable to call doublemonitor module as function
-----------------------------------------------------------------------------------------------------------------------
function doublemonitor.mt:__call(...)
	return doublemonitor.new(...)
end

return setmetatable(doublemonitor, doublemonitor.mt)
