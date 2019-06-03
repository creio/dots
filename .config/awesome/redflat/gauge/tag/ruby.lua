-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat tag widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget to display tag info
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
local rubytag = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width        = 50,
		base = { pad = 5, height = 12, thickness = 2 },
		mark = { pad = 10, height = 4 },
		color        = { main  = "#b1222b", gray  = "#575757", icon = "#a0a0a0", urgent = "#32882d" }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.ruby") or {})
end

-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function rubytag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		width = style.width or nil
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = state
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
	function widg:draw(_, cr, width, height)

		-- state
		local cl = data.state.active and style.color.main or style.color.gray
		cr:set_source(color(cl))

		cr:rectangle(
			style.base.pad, math.floor((height - style.base.height) / 2),
			width - 2 * style.base.pad, style.base.height
		)
		cr:set_line_width(style.base.thickness)
		cr:stroke()

		-- focus
		cl = data.state.focus and style.color.main
		     or data.state.urgent and style.color.urgent
		     or (data.state.occupied and  style.color.icon or style.color.gray)
		cr:set_source(color(cl))

		cr:rectangle(
			style.mark.pad, math.floor((height - style.mark.height) / 2),
			width - 2 * style.mark.pad, style.mark.height
		)

		cr:fill()
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call rubytag module as function
-----------------------------------------------------------------------------------------------------------------------
function rubytag.mt:__call(...)
	return rubytag.new(...)
end

return setmetatable(rubytag, rubytag.mt)
