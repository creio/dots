-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat promt widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Promt widget with his own wibox placed on center of screen
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.prompt v3.5.2
------ (c) 2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local type = type
local unpack = unpack or table.unpack

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local redutil = require("redflat.util")
local decoration = require("redflat.float.decoration")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local floatprompt = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry     = { width = 620, height = 120 },
		margin       = { 20, 20, 40, 40 },
		border_width = 2,
		naughty      = {},
		color        = { border = "#575757", wibox = "#202020" },
		shape        = nil
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.prompt") or {})
end

-- Initialize prompt widget
-- @param prompt Prompt to use
-----------------------------------------------------------------------------------------------------------------------
function floatprompt:init(args)

	args = args or {}
	local style = default_style()
	self.style = style

	-- Create prompt widget
	--------------------------------------------------------------------------------
	self.widget = wibox.widget.textbox()
	self.widget:set_ellipsize("start")
	self.prompt = args.prompt or " Run: "
	self.decorated_widget = decoration.textfield(self.widget, style.field)

	-- Create floating wibox for promt widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	self.wibox:set_widget(wibox.container.margin(self.decorated_widget, unpack(style.margin)))
	self.wibox:geometry(style.geometry)
end

-- Run method for prompt widget
-- Wibox appears on call and hides after command entered
-----------------------------------------------------------------------------------------------------------------------
function floatprompt:run()
	if not self.wibox then self:init() end
	redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
	self.wibox.visible = true

	awful.prompt.run({
		prompt = self.prompt,
		textbox = self.widget,
		exe_callback = function(input)
			local result = awful.spawn(input)
			if type(result) == "string" then
				local notify_args = redutil.table.merge({ title = "Prompt", text = result }, self.style.naughty)
				naughty.notify(notify_args)
			end
		end,
		history_path = awful.util.getdir("cache") .. "/history",
		history_max = 30,
		completion_callback = awful.completion.shell,
		done_callback = function () self.wibox.visible = false end,
	})
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return floatprompt
