-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat decorations                                                --
-----------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local decor = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function button_style()
	local style = {
		color = { shadow3 = "#1c1c1c", button = "#575757",
		          shadow4 = "#767676", text = "#cccccc", pressed = "404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.decoration.button") or {})
end

local function field_style()
	local style = {
		color = { bg = "#161616", shadow1 = "#141414", shadow2 = "#313131" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.decoration.field") or {})
end

-- Button element
-----------------------------------------------------------------------------------------------------------------------
function decor.button(textbox, action, style)

	style = redutil.table.merge(button_style(), style or {})

	-- Widget and layouts
	--------------------------------------------------------------------------------
	textbox:set_align("center")
	local button_widget = wibox.container.background(textbox, style.color.button)
	button_widget:set_fg(style.color.text)

	local bord1 = wibox.container.background(wibox.container.margin(button_widget, 1, 1, 1, 1), style.color.shadow4)
	local bord2 = wibox.container.background(wibox.container.margin(bord1, 1, 1, 1, 1), style.color.shadow3)

	-- Button
	--------------------------------------------------------------------------------
	local press_func = function()
		button_widget:set_bg(style.color.pressed)
	end
	local release_func = function()
		button_widget:set_bg(style.color.button)
		action()
	end

	button_widget:buttons(awful.button({}, 1, press_func, release_func))

	-- Signals
	--------------------------------------------------------------------------------
	button_widget:connect_signal(
		"mouse::leave",
		function()
			button_widget:set_bg(style.color.button)
		end
	)

	--------------------------------------------------------------------------------
	return bord2
end

-- Input text field
-----------------------------------------------------------------------------------------------------------------------
function decor.textfield(textbox, style)
	style = redutil.table.merge(field_style(), style or {})
	local field = wibox.container.background(textbox, style.color.bg)
	local bord1 = wibox.container.background(wibox.container.margin(field, 1, 1, 1, 1), style.color.shadow1)
	local bord2 = wibox.container.background(wibox.container.margin(bord1, 1, 1, 1, 1), style.color.shadow2)
	return bord2
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return decor
