-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat tag widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget to display tag info
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local unpack = unpack or table.unpack

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local greentag = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width    = 80,
		margin   = { 2, 2, 2, 2 },
		icon     = { unknown = redutil.base.placeholder() },
		color    = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d" },
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.green") or {})
end


-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function greentag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = {},
		width = style.width or nil
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.layout.align.horizontal()
	widg._svgbox = svgbox()
	widg:set_middle(wibox.container.margin(widg._svgbox, unpack(style.margin)))
	widg:set_forced_width(data.width)
	widg:set_expand("outside")

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = state
		local icon = style.icon[awful.layout.getname(state.layout)] or style.icon.unknown
		self._svgbox:set_image(icon)
		self._svgbox:set_color(
			data.state.active and style.color.main
			or data.state.urgent and style.color.urgent
			or data.state.occupied and style.color.icon
			or style.color.gray
		)
	end

	function widg:set_width(width)
		data.width = width
		self.set_forced_width(width)
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call greentag module as function
-----------------------------------------------------------------------------------------------------------------------
function greentag.mt:__call(...)
	return greentag.new(...)
end

return setmetatable(greentag, greentag.mt)
