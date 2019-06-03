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
local orangetag = { mt = {} }
local TPI = math.pi * 2

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width        = 50,
		line_width   = 4,
		radius       = 14,
		iradius      = 6,
		cgap         = TPI / 20,
		show_min     = true,
		min_sections = 1,
		color        = { main  = "#b1222b", gray  = "#575757", icon = "#a0a0a0", urgent = "#32882d" }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.orange") or {})
end

-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function orangetag.new(style)

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

		local sections = math.max(#data.state.list, style.min_sections)
		local step = (TPI - sections * style.cgap) / sections
		local cl

		-- active mark
		cl = data.state.active and style.color.main or (data.state.occupied and  style.color.icon or style.color.gray)
		cr:set_source(color(cl))

		cr:arc(width / 2, height / 2, style.iradius, 0, TPI)
		cr:fill()

		-- occupied mark
		cr:set_line_width(style.line_width)
		for i = 1, sections do
			local cs = -TPI / 4 + (i - 1) * (step + style.cgap) + style.cgap / 2

			if data.state.list[i] then
				cl = data.state.list[i].focus and style.color.main or
				     data.state.list[i].urgent and style.color.urgent or
				     data.state.list[i].minimized and style.show_min and style.color.gray or style.color.icon
			else
				cl = style.color.gray
			end

			cr:set_source(color(cl))
			if sections == 1 then
				cr:arc(width / 2, height / 2, style.radius, 0, TPI)
			else
				cr:arc(width / 2, height / 2, style.radius, cs, cs + step)
			end
			cr:stroke()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call orangetag module as function
-----------------------------------------------------------------------------------------------------------------------
function orangetag.mt:__call(...)
	return orangetag.new(...)
end

return setmetatable(orangetag, orangetag.mt)
