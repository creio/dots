-----------------------------------------------------------------------------------------------------------------------
--                                      RedFlat simple line desktop widget                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string

local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local textbox = require("redflat.desktop.common.textbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local sline = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		lbox      = { draw = "by_left", width = 50 },
		rbox      = { draw = "by_right", width = 50 },
		digits    = 3,
		icon      = nil,
		iwidth    = 120,
		unit      = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color     = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.singleline") or {})
end

local default_args = { timeout = 60, sensors = {} }

-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function sline.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	args = redutil.table.merge(default_args, args or {})
	style = redutil.table.merge(default_style(), style or {})

	dwidget.style = style

	-- Initialize layouts
	--------------------------------------------------------------------------------
	dwidget.item = {}
	dwidget.icon = {}
	dwidget.area = wibox.layout.align.horizontal()

	local mid = wibox.layout.flex.horizontal()

	-- construct line
	for i, _ in ipairs(args.sensors) do
		dwidget.item[i] = textbox("", style.rbox)

		if style.icon then dwidget.icon[i] = svgbox(style.icon) end

		local boxlayout = wibox.widget({
			textbox(string.upper(args.sensors[i].name or "mon"), style.lbox),
			style.icon and {
				nil, dwidget.icon[i], nil,
				expand = "outside",
				layout = wibox.layout.align.horizontal
			},
			dwidget.item[i],
			forced_width = style.iwidth,
			layout = wibox.layout.align.horizontal
		})

		if i == 1 then
			dwidget.area:set_left(boxlayout)
		else
			local space = wibox.layout.align.horizontal()
			space:set_right(boxlayout)
			mid:add(space)
		end
	end

	dwidget.area:set_middle(mid)

	-- Update info function
	--------------------------------------------------------------------------------
	local function set_raw_state(state, crit, i)
		local text_color = crit and state[1] > crit and style.color.main or style.color.gray
		local txt = redutil.text.dformat(state[2] or state[1], style.unit, style.digits)

		dwidget.item[i]:set_text(txt)
		dwidget.item[i]:set_color(text_color)

		if dwidget.icon[i] then
			local icon_color = state.off and style.color.gray or style.color.main
			dwidget.icon[i]:set_color(icon_color)
		end
	end

	local function item_hadnler(crit, i)
		return function(state) set_raw_state(state, crit, i) end
	end

	local function update()
		for i, sens in ipairs(args.sensors) do
			local crit = sens.crit
			if sens.meter_function then
				local state = sens.meter_function(sens.args)
				set_raw_state(state, crit, i)
			else
				sens.async_function(item_hadnler(crit, i))
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
function sline.mt:__call(...)
	return sline.new(...)
end

return setmetatable(sline, sline.mt)
