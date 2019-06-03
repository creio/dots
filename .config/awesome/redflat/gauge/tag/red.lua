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
local redtag = { mt = {} }

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

local function fill_geometry(width, height, geometry)
	local zero_geometry = { x = 0, y = 0, width = width, height = height }
	return redutil.table.merge(zero_geometry, geometry)
end

-- Cairo drawing functions
--------------------------------------------------------------------------------
local cairo_draw = {}

-- Tag active mark (line)
------------------------------------------------------------
function cairo_draw.active(cr, width, height, geometry)
	geometry = fill_geometry(width, height, geometry)

	cr:rectangle(geometry.x, geometry.y, geometry.width, geometry.height)
	cr:fill()
end

-- Tag focus mark (rhombus)
------------------------------------------------------------
function cairo_draw.focus(cr, width, height, geometry)
	geometry = fill_geometry(width, height, geometry)

	cr:move_to(geometry.x + geometry.width / 2, geometry.y)
	cr:rel_line_to(geometry.width / 2, geometry.height / 2)
	cr:rel_line_to(- geometry.width / 2, geometry.height / 2)
	cr:rel_line_to(- geometry.width / 2, - geometry.height / 2)
	cr:close_path()
	cr:fill()
end

-- Tag occupied mark (label)
------------------------------------------------------------
function cairo_draw.occupied(cr, width, height, geometry)
	geometry = fill_geometry(width, height, geometry)

	cr:move_to(geometry.x, geometry.y)
	cr:rel_line_to(0, geometry.height)
	cr:rel_line_to(geometry.width / 2, - geometry.width / 2)
	cr:rel_line_to(geometry.width / 2, geometry.width / 2)
	cr:rel_line_to(0, - geometry.height)
	cr:close_path()
	cr:fill()
end


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width        = 80,
		font         = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_shift   = 22,
		counter      = { size = 12, margin = 2, coord = { 40, 35 } },
		show_counter = true,
		color        = { main   = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d",
		                 wibox = "#202020" }
	}

	-- functions for state marks
	style.marks = cairo_draw

	-- geometry for state marks
	style.geometry = {
		active    = { height = 5, y = 45 },
		focus     = { x = 5, y = 10, width = 10, height = 15 },
		occupied  = { x = 65, y = 10, width = 10, height = 15 }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.red") or {})
end

-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function redtag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = { text = "TEXT" },
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

		-- text
		cr:set_source(color(style.color.icon))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.textcentre.horizontal(cr, { width/2, style.text_shift }, data.state.text)

		-- active mark
		cr:set_source(color(data.state.active and style.color.main or style.color.gray))
		style.marks.active(cr, width, height, style.geometry.active)

		-- occupied mark
		if data.state.occupied then
			cr:set_source(color(data.state.urgent and style.color.urgent or style.color.main))
			style.marks.occupied(cr, width, height, style.geometry.occupied)
		end

		-- focus mark
		if data.state.focus then
			cr:set_source(color(style.color.main))
			style.marks.focus(cr, width, height, style.geometry.focus)
		end

		-- counter
		if style.show_counter and #data.state.list > 0 then
			cr:set_font_size(style.counter.size)
			local ext = cr:text_extents(tostring(#data.state.list))
			cr:set_source(color(style.color.wibox))
			cr:rectangle(
				style.counter.coord[1] - ext.width / 2 - style.counter.margin,
				style.counter.coord[2] - ext.height / 2 - style.counter.margin,
				ext.width + 2 * style.counter.margin,
				ext.height + 2 * style.counter.margin
			)
			cr:fill()

			cr:set_source(color(style.color.icon))
			redutil.cairo.textcentre.full(cr, style.counter.coord, tostring(#data.state.list))
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call redtag module as function
-----------------------------------------------------------------------------------------------------------------------
function redtag.mt:__call(...)
	return redtag.new(...)
end

return setmetatable(redtag, redtag.mt)
