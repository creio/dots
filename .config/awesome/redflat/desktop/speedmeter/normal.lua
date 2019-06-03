-----------------------------------------------------------------------------------------------------------------------
--                                       RedFlat speed meter deskotp widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Network or disk i/o speed indicators
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable

local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local system = require("redflat.system")
local redutil = require("redflat.util")
local dcommon = require("redflat.desktop.common")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local speedmeter = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		images           = {},
		label            = { height = 20, separator = "^" },
		progressbar      = { chunk = { width = 10, gap = 5 }, height = 4 },
		chart            = {},
		barvalue_height  = 32,
		fullchart_height = 78,
		digits           = 2,
		image_gap        = 20,
		unit             = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color            = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.speedmeter.normal") or {})
end

local default_args = {
	autoscale = true,
	label = "NETWORK",
	timeout = 5,
	interface = "eth0",
	meter_function = system.net_speed
}

local default_maxspeed = { up = 10 * 1024, down = 10 * 1024 }


-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function set_fullchart_info(objects, label, state, style)
	for i, o in ipairs(objects) do
		o.barvalue:set_value(state[i])
		o.barvalue:set_text(
			label .. style.label.separator .. redutil.text.dformat(state[i], style.unit, style.digits, " ")
		)
		o.chart:set_value(state[i])
	end
end

local function colorize_icon(objects, last_state, values, crit, style)
	for i, o in ipairs(objects) do
		local st = values[i] > crit[i]
		if st ~= last_state[i] then
			o:set_color(st and style.color.main or style.color.gray)
			last_state[i] = st
		end
	end
end

-- Construct complex indicator with progress bar and label on top of it
--------------------------------------------------------------------------------
local function barvalue(progressbar_style, label_style)
	local widg = {}

	-- construct layout with indicators
	local progressbar = dcommon.bar.plain(progressbar_style)
	local label = dcommon.textbox(nil, label_style)

	widg.layout = wibox.widget({
		label, nil, progressbar,
		layout = wibox.layout.align.vertical,
	})

	-- setup functions
	function widg:set_text(text) label:set_text(text) end
	function widg:set_value(x) progressbar:set_value(x) end

	return widg
end

-- Construct complex indicator with history chart, progress bar and label
--------------------------------------------------------------------------------
local function fullchart(label_style, progressbar_style, chart_style, barvalue_height, maxm)

	local widg = {}
	chart_style = redutil.table.merge(chart_style, { maxm = maxm })
	progressbar_style = redutil.table.merge(progressbar_style, { maxm = maxm })

	-- construct layout with indicators
	widg.barvalue = barvalue(progressbar_style, label_style)
	widg.chart = dcommon.chart(chart_style)
	widg.barvalue.layout:set_forced_height(barvalue_height)

	widg.layout = wibox.widget({
		widg.barvalue.layout, nil, widg.chart,
		layout = wibox.layout.align.vertical,
	})

	return widg
end

-- Construct speed info elements (fullchart and icon in one layout)
--------------------------------------------------------------------------------
local function speed_line(image, maxm, el_style, style)
	local fc = fullchart(el_style.label, el_style.progressbar, el_style.chart, style.barvalue_height, maxm)
	local align = wibox.layout.align.horizontal()
	local icon

	align:set_right(fc.layout)
	align:set_forced_height(style.fullchart_height)

	if image then
		icon = svgbox(image)
		icon:set_color(style.color.gray)
		align:set_left(wibox.container.margin(icon, 0, style.image_gap))
	end

	return fc, align, icon
end


-- Create a new speed meter widget
-----------------------------------------------------------------------------------------------------------------------
function speedmeter.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local storage = {}
	local last = {}

	args = redutil.table.merge(default_args, args or {})
	style = redutil.table.merge(default_style(), style or {})
	local maxspeed = redutil.table.merge(default_maxspeed, args.maxspeed or {})

	local elements_style = {
		label = redutil.table.merge(style.label, { draw = "by_edges", color = style.color.gray }),
		progressbar = redutil.table.merge(style.progressbar, { autoscale = args.autoscale, color = style.color }),
		chart = redutil.table.merge(style.chart, { autoscale = args.autoscale, color = style.color.gray })
	}

	dwidget.style = style

	-- Construct indicators
	--------------------------------------------------------------------------------
	local up_widget, up_layout, up_icon = speed_line(style.images[1], maxspeed.up, elements_style, style)
	local down_widget, down_layout, down_icon = speed_line(style.images[2], maxspeed.down, elements_style, style)

	dwidget.area = wibox.widget({
		up_layout, nil, down_layout,
		layout = wibox.layout.align.vertical
	})

	-- Update info
	--------------------------------------------------------------------------------
	local function update()
		local state = args.meter_function(args.interface, storage)

		set_fullchart_info({ up_widget, down_widget }, args.label, state, style)

		if style.images and args.crit then
			colorize_icon({ up_icon, down_icon }, last, state, { args.crit.up, args.crit.down }, style)
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
function speedmeter.mt:__call(...)
	return speedmeter.new(...)
end

return setmetatable(speedmeter, speedmeter.mt)
