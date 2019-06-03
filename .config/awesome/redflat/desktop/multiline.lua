-----------------------------------------------------------------------------------------------------------------------
--                                         RedFlat dashpack desktop widget                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-- Several lines with progressbar, label and text
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string
local unpack = unpack or table.unpack

local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local lines = require("redflat.desktop.common.pack.lines")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dashpack = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon      = { image = nil, margin = { 0, 0, 0, 0 } },
		lines     = {},
		margin    = { 0, 0, 0, 0 },
		digits    = 3,
		dislabel  = "OFF",
		unit      = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color     = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.multiline") or {})
end

local default_args = { timeout = 60, sensors = {} }

-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function dashpack.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	args = redutil.table.merge(default_args, args or {})
	style = redutil.table.merge(default_style(), style or {})
	local alert_data = { counter = 0, state = false }

	dwidget.style = style

	-- initialize progressbar lines
	local lines_style = redutil.table.merge(style.lines, { color = style.color })
	local pack = lines(#args.sensors, lines_style)

	-- add icon if needed
	if style.icon.image then
		dwidget.icon = svgbox(style.icon.image)
		dwidget.icon:set_color(style.color.gray)

		dwidget.area = wibox.layout.align.horizontal()
		dwidget.area:set_middle(wibox.container.margin(pack.layout, unpack(style.margin)))
		dwidget.area:set_left(wibox.container.margin(dwidget.icon, unpack(style.icon.margin)))
	else
		dwidget.area = wibox.container.margin(pack.layout, unpack(style.margin))
	end

	for i, sensor in ipairs(args.sensors) do
		if sensor.name then pack:set_label(string.upper(sensor.name), i) end
	end

	-- Update info function
	--------------------------------------------------------------------------------
	local function set_raw_state(state, maxm, crit, i)
		local alert = crit and state[1] > crit
		local text_color = alert and style.color.main or style.color.gray

		pack:set_values(state[1] / maxm, i)
		pack:set_label_color(text_color, i)

		if style.lines.show.text or style.lines.show.tooltip then
			local txt = state.off and style.dislabel
			            or redutil.text.dformat(state[2] or state[1], style.unit, style.digits)
			pack:set_text(txt, i)
			pack:set_text_color(text_color, i)
		end

		if style.icon.image then
			alert_data.counter = alert_data.counter + 1
			alert_data.state = alert_data.state or alert
			if alert_data.counter == #args.sensors then
				dwidget.icon:set_color(alert_data.state and style.color.main or style.color.gray)
			end
		end
	end

	local function line_hadnler(maxm, crit, i)
		return function(state) set_raw_state(state, maxm, crit, i) end
	end

	local function update()
		alert_data = { counter = 0, state = false }
		--if style.icon.image then dwidget.icon:set_color(style.color.gray) end
		for i, sens in ipairs(args.sensors) do
			local maxm, crit = sens.maxm, sens.crit
			if sens.meter_function then
				local state = sens.meter_function(sens.args)
				set_raw_state(state, maxm, crit, i)
			else
				sens.async_function(line_hadnler(maxm, crit, i))
			end
		end
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = args.timeout })
	t:connect_signal("timeout", update)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return dwidget
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function dashpack.mt:__call(...)
	return dashpack.new(...)
end

return setmetatable(dashpack, dashpack.mt)
