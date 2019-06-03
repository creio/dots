-----------------------------------------------------------------------------------------------------------------------
--                                                 RedFlat battery widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Battery charge monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local beautiful = require("beautiful")
local timer = require("gears.timer")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local monitor = require("redflat.gauge.monitor.plain")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local battery = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		timeout = 60,
		width   = nil,
		widget  = monitor.new,
		notify  = {},
		levels  = { 0.05, 0.1, 0.15 }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.battery") or {})
end

-- Support fucntions
-----------------------------------------------------------------------------------------------------------------------
local get_level = function(value, line)
	for _, v in ipairs(line) do
		if value < v then return v end
	end
end

-- Create a system monitoring widget with additional notification
-----------------------------------------------------------------------------------------------------------------------
function battery.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	style = redutil.table.merge(default_style(), style or {})

	-- Create monitor widget
	--------------------------------------------------------------------------------
	local widg = style.widget(style.monitor)
	widg._last = { value = 1, level = 1 }

	-- Set tooltip
	--------------------------------------------------------------------------------
	widg._tp = tooltip({ objects = { widg } }, style.tooltip)

	-- Set update timer
	--------------------------------------------------------------------------------
	widg._update = function()
		local state = args.func(args.arg)

		widg:set_value(state.value)
		widg:set_alert(state.alert)
		widg._tp:set_text(state.text)

		if state.value <= widg._last.value then
			local level = get_level(state.value, style.levels)
			if level and level ~= widg._last.level then
				widg._last.level = level
				local warning = string.format("Battery charge < %.0f%%", level * 100)
				rednotify:show(redutil.table.merge({ text = warning }, style.notify))
			end
		else
			widg._last.level = nil
		end

		widg._last.value = state.value
	end

	widg._timer = timer({ timeout = style.timeout })
	widg._timer:connect_signal("timeout", function() widg._update() end)
	widg._timer:start()
	widg._timer:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function battery.mt:__call(...)
	return battery.new(...)
end

return setmetatable(battery, battery.mt)
