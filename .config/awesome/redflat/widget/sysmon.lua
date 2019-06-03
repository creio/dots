-----------------------------------------------------------------------------------------------------------------------
--                                                 RedFlat sysmon widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local beautiful = require("beautiful")
local timer = require("gears.timer")

local monitor = require("redflat.gauge.monitor.plain")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local sysmon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		timeout = 5,
		width   = nil,
		widget  = monitor.new
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.sysmon") or {})
end

-- Create a new cpu monitor widget
-----------------------------------------------------------------------------------------------------------------------
function sysmon.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	style = redutil.table.merge(default_style(), style or {})

	-- Create monitor widget
	--------------------------------------------------------------------------------
	local widg = style.widget(style.monitor)

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
function sysmon.mt:__call(...)
	return sysmon.new(...)
end

return setmetatable(sysmon, sysmon.mt)
