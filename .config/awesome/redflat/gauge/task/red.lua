-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat task widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget includes label and decorative line
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
local redtask = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width      = 40,
		line       = { height = 4, y = 30 },
		font       = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_shift = 22,
		counter    = { size = 12, margin = 2 },
		color      = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0",
		               urgent = "#32882d", wibox = "#202020" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.task.red") or {})
end

-- Create a new redtask widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function redtask.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = { text = "TXT" }
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = redutil.table.merge(data.state, state)
		self:emit_signal("widget::redraw_needed")
	end

	function widg:set_width(width)
		data.width = width
		self:emit_signal("widget::redraw_needed")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		if data.width then
			return math.min(width, data.width), height
		else
			return width, height
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width)

		-- label
		cr:set_source(color(data.state.minimized and style.color.gray or style.color.icon))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.textcentre.horizontal(cr, { width / 2, style.text_shift }, data.state.text)

		-- line
		local line_color = data.state.focus and style.color.main
		                   or data.state.urgent and style.color.urgent
		                   or style.color.gray
		cr:set_source(color(line_color))
		cr:rectangle(0, style.line.y, width, style.line.height)
		cr:fill()

		-- counter
		if data.state.num > 1 then
			cr:set_font_size(style.counter.size)
			local ext = cr:text_extents(tostring(data.state.num))
			cr:set_source(color(style.color.wibox))
			cr:rectangle(
				(width - ext.width) / 2 - style.counter.margin, style.line.y,
				ext.width + 2 * style.counter.margin, style.counter.size
			)
			cr:fill()

			cr:set_source(color(style.color.icon))
			local coord = { width / 2, style.line.y + style.counter.size / 2 }
			redutil.cairo.textcentre.horizontal(cr, coord, tostring(data.state.num))
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call redtask module as function
-----------------------------------------------------------------------------------------------------------------------
function redtask.mt:__call(...)
	return redtask.new(...)
end

return setmetatable(redtask, redtask.mt)
