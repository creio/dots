-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat multi monitoring deskotp widget                                       --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-- Pack of vertical indicators and two lines with labeled progressbar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
--local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")
local unpack = unpack or table.unpack

local dcommon = require("redflat.desktop.common")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local multim = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		lines          = {},
		upbar          = { width = 40 },
		digits         = 3,
		height         = { upright = 100, lines = 60 },
		icon           = { image = nil, margin = { 0, 20, 0, 0 }, full = false },
		labels         = {},
		unit           = { { "MB", - 1 }, { "GB", 1024 } },
		color          = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.multimeter") or {})
end

local default_args = {
	topbars = { num = 1, maxm = 1},
	lines   = { maxm = 1 },
	meter   = {},
	timeout = 60,
}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function set_info(value, args, upright, lines, icon, last, style)
	local upright_alert = value.alert

	-- set progressbar values and color
	for i, line in ipairs(args.lines) do
		lines:set_values(value.lines[i][1] / line.maxm, i)
		lines:set_text(redutil.text.dformat(value.lines[i][2], line.unit or style.unit, style.digits), i)

		if line.crit then
			local cc = value.lines[i][1] > line.crit and style.color.main or style.color.gray
			lines:set_text_color(cc, i)
			if style.labels[i] then lines:set_label_color(cc, i) end
		end
	end

	-- set upright value
	for i = 1, args.topbars.num do
		local v = value.bars[i] and value.bars[i].value or 0
		local tip = value.bars[i] and value.bars[i].text or nil
		upright:set_values(v / args.topbars.maxm, i, tip)
		if args.topbars.crit then upright_alert = upright_alert or v > args.topbars.crit end
	end

	-- colorize icon if needed
	if style.icon.image and upright_alert ~= last.alert then
		icon:set_color(upright_alert and style.color.main or style.color.gray)
		last.alert = upright_alert
	end
end


-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function multim.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local icon
	local last = { alert = false }

	args = redutil.table.merge(default_args, args or {})
	--local geometry = redutil.table.merge(default_geometry, geometry or {})
	style = redutil.table.merge(default_style(), style or {})

	local lines_style = redutil.table.merge(style.lines, { progressbar = { color = style.color } })
	local upbar_style = redutil.table.merge(style.upbar, { color = style.color })

	dwidget.style = style

	-- Construct layouts
	--------------------------------------------------------------------------------
	local lines = dcommon.pack.lines(#args.lines, lines_style)
	local upright = dcommon.pack.upright(args.topbars.num, upbar_style)
	lines.layout:set_forced_height(style.height.lines)

	if style.icon.image then
		icon = svgbox(style.icon.image)
		icon:set_color(style.color.gray)
	end

	dwidget.area = wibox.widget({
		{
			icon and not style.icon.full and wibox.container.margin(icon, unpack(style.icon.margin)),
			upright.layout,
			nil,
			forced_height = style.height.upright,
			layout = wibox.layout.align.horizontal
		},
		nil,
		lines.layout,
		layout = wibox.layout.align.vertical
	})

	if icon and style.icon.full then
		dwidget.area = wibox.widget({
			wibox.container.margin(icon, unpack(style.icon.margin)),
			dwidget.area,
			nil,
			layout = wibox.layout.align.horizontal
		})
	end

	for i, label in ipairs(style.labels) do
		lines:set_label(label, i)
	end

	-- Update info function
	--------------------------------------------------------------------------------
	local function raw_set(state)
		set_info(state, args, upright, lines, icon, last, style)
	end

	local function update_plain()
		local state = args.meter.func(args.meter.args)
		set_info(state, args, upright, lines, icon, last, style)
	end

	local update = args.meter.async and function() args.meter.async(raw_set, args.meter.args) end or update_plain

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
function multim.mt:__call(...)
	return multim.new(...)
end

return setmetatable(multim, multim.mt)
