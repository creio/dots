-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat tooltip                                                  --
-----------------------------------------------------------------------------------------------------------------------
-- Slightly modded awful tooltip
-- padding added
-- Proper placement on every text update
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.tooltip v3.5.2
------ (c) 2009 Sébastien Gross
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs = ipairs
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local tooltip = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		padding      = { vertical = 3, horizontal = 5 },
		timeout      = 1,
		font  = "Sans 12",
		border_width = 2,
		set_position = nil,
		color        = { border = "#404040", text = "#aaaaaa", wibox = "#202020" },
		shape        = nil
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.tooltip") or {})
end

-- Create a new tooltip
-----------------------------------------------------------------------------------------------------------------------
function tooltip.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local objects = args.objects or {}
	style = redutil.table.merge(default_style(), style or {})

	-- Construct tooltip window with wibox and textbox
	--------------------------------------------------------------------------------
	local ttp = { wibox = wibox({ type = "tooltip" }), tip = nil }
	local tb = wibox.widget.textbox()
	tb:set_align("center")

	ttp.widget = tb
	ttp.wibox:set_widget(tb)
	tb:set_font(style.font)

	-- configure wibox properties
	ttp.wibox.visible = false
	ttp.wibox.ontop = true
	ttp.wibox.border_width = style.border_width
	ttp.wibox.border_color = style.color.border
	ttp.wibox.shape = style.shape
	ttp.wibox:set_bg(style.color.wibox)
	ttp.wibox:set_fg(style.color.text)

	-- Tooltip size configurator
	--------------------------------------------------------------------------------
	function ttp:set_geometry()
		local wibox_sizes = self.wibox:geometry()
		local w, h = self.widget:get_preferred_size()
		local requsted_width = w + 2*style.padding.horizontal
		local requsted_height = h + 2*style.padding.vertical

		if wibox_sizes.width ~= requsted_width or wibox_sizes.height ~= requsted_height then
			self.wibox:geometry({
				width = requsted_width,
				height = requsted_height
			})
		end
	end

	-- Set timer to make delay before tooltip show
	--------------------------------------------------------------------------------
	local show_timer = timer({ timeout = style.timeout })
	show_timer:connect_signal("timeout",
		function()
			ttp:set_geometry()
			if style.set_position then
				style.set_position(ttp.wibox)
			else
				awful.placement.under_mouse(ttp.wibox)
			end
			awful.placement.no_offscreen(ttp.wibox)
			ttp.wibox.visible = true
			show_timer:stop()
		end)

	-- Tooltip metods
	--------------------------------------------------------------------------------
	function ttp.show()
		if not show_timer.started then show_timer:start() end
	end

	function ttp.hide()
		if show_timer.started then show_timer:stop() end
		if ttp.wibox.visible then ttp.wibox.visible = false end
	end

	function ttp:set_text(text)
		if self.tip ~= text then
			self.widget:set_text(text)
			self.tip = text

			if self.wibox.visible then
				self:set_geometry()
				self.wibox.x = mouse.coords().x - self.wibox.width / 2
				awful.placement.no_offscreen(self.wibox)
			end
		end
	end

	function ttp:add_to_object(object)
		object:connect_signal("mouse::enter", self.show)
		object:connect_signal("mouse::leave", self.hide)
	end

	function ttp:remove_from_object(object)
		object:disconnect_signal("mouse::enter", self.show)
		object:disconnect_signal("mouse::leave", self.hide)
	end

	-- Add tooltip to objects
	--------------------------------------------------------------------------------
	if objects then
		for _, object in ipairs(objects) do
			ttp:add_to_object(object)
		end
	end

	--------------------------------------------------------------------------------
	return ttp
end

-- Config metatable to call tooltip module as function
-----------------------------------------------------------------------------------------------------------------------
function tooltip.mt:__call(...)
	return tooltip.new(...)
end

return setmetatable(tooltip, tooltip.mt)
