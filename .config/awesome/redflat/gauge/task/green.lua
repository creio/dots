-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat task widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget includes colored icon
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local unpack = unpack or table.unpack

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local greentask = { mt = {} }


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width        = 40,
		margin       = { 0, 0, 0, 0 },
		df_icon      = redutil.base.placeholder(),
		counter      = { font = "Sans 10", mask = "%d" },
		color        = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d", wibox = "#202020" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.task.green") or {})
end


-- Create a new greentask widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function greentask.new(style)

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
	local widg = wibox.layout.stack()

	widg._svgbox = svgbox()
	widg._textbox = wibox.widget{
		align  = 'center',
		valign = 'bottom',
		font   = style.counter.font,
		widget = wibox.widget.textbox
	}

	widg._icon_layout = wibox.widget({
		nil, wibox.container.margin(widg._svgbox, unpack(style.margin)),
		layout = wibox.layout.align.horizontal,
		expand = "outside",
	})
	widg._text_layout = wibox.widget({
		nil, nil, widg._textbox,
		-- nil, nil, wibox.container.background(widg._textbox, style.color.wibox),
		layout = wibox.layout.align.vertical,
	})

	widg:add(widg._icon_layout)
	widg:add(widg._text_layout)
	widg:set_forced_width(data.width)

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = redutil.table.merge(data.state, state)

		-- icon
		local icon = state.icon or style.df_icon
		self._svgbox:set_image(icon)
		self._svgbox:set_color(
			data.state.focus and style.color.main
			or data.state.urgent and style.color.urgent
			or data.state.minimized and style.color.gray
			or style.color.icon
		)

		-- counter
		self._text_layout:set_visible(state.num > 1)
		self._textbox:set_markup(
			string.format('<span background="%s">' .. style.counter.mask .. '</span>', style.color.wibox, state.num)
		)
	end

	function widg:set_width(width)
		data.width = width
		self.set_forced_width(width)
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call greentask module as function
-----------------------------------------------------------------------------------------------------------------------
function greentask.mt:__call(...)
	return greentask.new(...)
end

return setmetatable(greentask, greentask.mt)
