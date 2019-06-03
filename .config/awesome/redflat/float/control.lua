-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat floating window manager                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Widget to control single flating window size and posioning
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local unpack = unpack or table.unpack

local beautiful = require("beautiful")
local awful     = require("awful")
local wibox     = require("wibox")

local rednotify = require("redflat.float.notify")
local redutil   = require("redflat.util")
local redtip    = require("redflat.float.hotkeys")
local svgbox    = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local control = {}

-- Resize mode alias
local RESIZE_MODE = { FULL = 1, HORIZONTAL = 2, VERTICAL = 3 }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry      = { width = 400, height = 60 },
		border_width  = 2,
		font          = "Sans 14",
		set_position  = nil,
		notify        = {},
		keytip        = { geometry = { width = 600 } },
		shape         = nil,
		steps         = { 1, 10, 20, 50 },
		default_step  = 2,
		onscreen      = true,
		margin        = { icon = { onscreen = { 10, 10, 2, 2 }, mode = { 10, 10, 2, 2 } } },
		icon          = {
			resize   = {},
			onscreen = redutil.base.placeholder({ txt = "X" }),
		},
		color         = { border = "#575757", text = "#aaaaaa", main = "#b1222b", wibox = "#202020",
		                  gray = "#575757", icon = "#a0a0a0" },
	}

	style.icon.resize[RESIZE_MODE.FULL] = redutil.base.placeholder({ txt = "F" })
	style.icon.resize[RESIZE_MODE.HORIZONTAL] = redutil.base.placeholder({ txt = "H" })
	style.icon.resize[RESIZE_MODE.VERTICAL] = redutil.base.placeholder({ txt = "V" })

	return redutil.table.merge(style, redutil.table.check(beautiful, "float.control") or {})
end

-- key bindings
control.keys = {}
control.keys.control = {
	{
		{ "Mod4" }, "c", function() control:center() end,
		{ description = "Put window at the center", group = "Window control" }
	},
	{
		{ "Mod4" }, "q", function() control:resize() end,
		{ description = "Increase window size", group = "Window control" }
	},
	{
		{ "Mod4" }, "a", function() control:resize(true) end,
		{ description = "Decrease window size", group = "Window control" }
	},
	{
		{ "Mod4" }, "l", function() control:move("right") end,
		{ description = "Move window to right", group = "Window control" }
	},
	{
		{ "Mod4" }, "j", function() control:move("left") end,
		{ description = "Move window to left", group = "Window control" }
	},
	{
		{ "Mod4" }, "k", function() control:move("bottom") end,
		{ description = "Move window to bottom", group = "Window control" }
	},
	{
		{ "Mod4" }, "i", function() control:move("top") end,
		{ description = "Move window to top", group = "Window control" }
	},
	{
		{ "Mod4" }, "n", function() control:switch_resize_mode() end,
		{ description = "Switch moving/resizing mode", group = "Mode" }
	},
	{
		{ "Mod4" }, "s", function() control:switch_onscreen() end,
		{ description = "Switch off screen check", group = "Mode" }
	},
}
control.keys.action = {
	{
		{ "Mod4" }, "Super_L", function() control:hide() end,
		{ description = "Close top list widget", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

control.keys.all = awful.util.table.join(control.keys.control, control.keys.action)

control._fake_keys = {
	{
		{}, "N", nil,
		{ description = "Select move/resize step", group = "Mode",
		  keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }
	},
}


-- Support function
-----------------------------------------------------------------------------------------------------------------------
local function control_off_screen(window)
	local wa = screen[mouse.screen].workarea
	local newg = window:geometry()

	if newg.width > wa.width then window:geometry({ width = wa.width, x = wa.x }) end
	if newg.height > wa.height then window:geometry({ height = wa.height, y = wa.y }) end

	redutil.placement.no_offscreen(window, nil, wa)
end

-- Initialize widget
-----------------------------------------------------------------------------------------------------------------------
function control:init()

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = default_style()
	self.style = style
	self.client = nil
	self.step = style.steps[style.default_step]

	self.resize_mode = RESIZE_MODE.FULL
	self.onscreen = style.onscreen

	-- Create floating wibox for top widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	self.wibox:geometry(style.geometry)

	-- Widget layout setup
	--------------------------------------------------------------------------------
	self.label = wibox.widget.textbox()
	self.label:set_align("center")
	self.label:set_font(style.font)

	self.onscreen_icon = svgbox(self.style.icon.onscreen)
	self.onscreen_icon:set_color(self.onscreen and self.style.color.main or self.style.color.icon)

	self.mode_icon = svgbox(self.style.icon.resize[self.resize_mode])
	self.mode_icon:set_color(self.style.color.icon)

	self.wibox:setup({
		wibox.container.margin(self.onscreen_icon, unpack(self.style.margin.icon.onscreen)),
		self.label,
		wibox.container.margin(self.mode_icon, unpack(self.style.margin.icon.mode)),
		layout = wibox.layout.align.horizontal
	})

	-- Keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if event == "release" then
			for _, k in ipairs(self.keys.action) do
				if redutil.key.match_grabber(k, mod, key) then k[3](); return end
			end
		else
			for _, k in ipairs(self.keys.all) do
				if redutil.key.match_grabber(k, mod, key) then k[3](); return end
			end
			if string.match("123456789", key) then self:choose_step(tonumber(key)) end
		end
	end

	-- First run actions
	--------------------------------------------------------------------------------
	self:set_keys()
end

-- Window control
-----------------------------------------------------------------------------------------------------------------------

-- Put window at center of screen
--------------------------------------------------------------------------------
function control:center()
	if not self.client then return end
	redutil.placement.centered(self.client, nil, mouse.screen.workarea)

	if self.onscreen then control_off_screen(self.client) end
	self:update()
end

-- Change window size
--------------------------------------------------------------------------------
function control:resize(is_shrinking)
	if not self.client then return end

	-- calculate new size
	local g = self.client:geometry()
	local d = self.step * (is_shrinking and -1 or 1)
	local newg

	if self.resize_mode == RESIZE_MODE.FULL then
		newg = { x = g.x - d, y = g.y - d, width = g.width + 2 * d, height = g.height + 2 * d }
	elseif self.resize_mode == RESIZE_MODE.HORIZONTAL then
		newg = { x = g.x - d, width = g.width + 2 * d  }
	elseif self.resize_mode == RESIZE_MODE.VERTICAL then
		newg = { y = g.y - d, height = g.height + 2 * d  }
	end

	-- validate new size
	if newg.height and newg.height <= 0 or newg.width and newg.width < 0 then return end

	-- apply new size
	self.client:geometry(newg)
	if self.onscreen then control_off_screen(self.client) end
	self:update()
end

-- Move by direction
--------------------------------------------------------------------------------
function control:move(direction)
	if not self.client then return end

	local g = self.client:geometry()
	local d = self.step * ((direction == "left" or direction == "top") and -1 or 1)

	if direction == "left" or direction == "right" then
		self.client:geometry({ x = g.x + d })
	else
		self.client:geometry({ y = g.y + d })
	end

	if self.onscreen then control_off_screen(self.client) end
end


-- Widget actions
-----------------------------------------------------------------------------------------------------------------------

-- Update
--------------------------------------------------------------------------------
function control:update()
	if not self.client then return end

	local g = self.client:geometry()
	local size_label = string.format("%sx%s", g.width, g.height)

	self.label:set_markup(string.format(
		'<span color="%s">%s</span><span color="%s"> [%d]</span>',
		self.style.color.text, size_label, self.style.color.gray, self.step
	))
end

-- Select move/resize step by index
--------------------------------------------------------------------------------
function control:choose_step(index)
	if self.style.steps[index] then self.step = self.style.steps[index] end
	self:update()
end

-- Switch resize mode
--------------------------------------------------------------------------------
function control:switch_resize_mode()
	self.resize_mode = self.resize_mode + 1
	if not awful.util.table.hasitem(RESIZE_MODE, self.resize_mode) then self.resize_mode = RESIZE_MODE.FULL end

	self.mode_icon:set_image(self.style.icon.resize[self.resize_mode])
end

-- Switch onscreen mode
--------------------------------------------------------------------------------
function control:switch_onscreen()
	self.onscreen = not self.onscreen
	self.onscreen_icon:set_color(self.onscreen and self.style.color.main or self.style.color.icon)

	if self.onscreen then
		control_off_screen(self.client)
		self:update()
	end
end

-- Show
--------------------------------------------------------------------------------
function control:show()
	if not self.wibox then self:init() end

	if not self.wibox.visible then
		-- check if focused client floating
		local layout = awful.layout.get(mouse.screen)
		local is_floating = client.focus and (client.focus.floating or layout.name == "floating")
		                    and not client.focus.maximized

		if not is_floating then
			rednotify:show(redutil.table.merge({ text = "No floating window focused" }, self.style.notify))
			return
		end
		self.client = client.focus

		-- show widget
		if self.style.set_position then
			self.style.set_position(self.wibox)
		else
			redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
		end
		redutil.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)

		self:update()
		self.wibox.visible = true
		awful.keygrabber.run(self.keygrabber)
		redtip:set_pack(
			"Floating window", self.tip, self.style.keytip.column, self.style.keytip.geometry,
			function() self:hide() end
		)
	end
end

-- Hide
--------------------------------------------------------------------------------
function control:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
	redtip:remove_pack()
	self.client = nil
end

-- Set user hotkeys
-----------------------------------------------------------------------------------------------------------------------
function control:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.control, self.keys.action) end
	end

	self.tip = awful.util.table.join(self.keys.all, self._fake_keys)
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return control
