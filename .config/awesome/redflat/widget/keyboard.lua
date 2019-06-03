-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat keyboard layout indicator widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- Indicate and switch keybord layout
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local awful = require("awful")
local beautiful = require("beautiful")

local tooltip = require("redflat.float.tooltip")
local redmenu = require("redflat.menu")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keybd = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon         = redutil.base.placeholder(),
		micon        = { blank = redutil.base.placeholder({ txt = " " }),
		                 check = redutil.base.placeholder({ txt = "+" }) },
		menu         = { color = { right_icon = "#a0a0a0" } },
		layout_color = { "#a0a0a0", "#b1222b" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.keyboard") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:init(layouts, style)

	-- initialize vars
	style = redutil.table.merge(default_style(), style or {})
	self.layouts = layouts or {}
	self.style = style
	self.objects = {}

	-- tooltip
	self.tp = tooltip({ objects = {} }, style.tooltip)

	-- construct list of layouts
	local menu_items = {}
	for i = 1, #layouts do
		local command = function() awesome.xkb_set_layout_group(i - 1) end
		table.insert(menu_items, { layouts[i], command, nil, style.micon.blank })
	end

	-- initialize menu
	self.menu = redmenu({ hide_timeout = 1, theme = style.menu, items = menu_items })
	if self.menu.items[1].right_icon then
		self.menu.items[1].right_icon:set_image(style.micon.check)
	end

	-- update layout data
	self.update = function()
		local layout = awesome.xkb_get_layout_group() + 1
		for _, w in ipairs(self.objects) do w:set_color(style.layout_color[layout] or "#000000") end

		-- update tooltip
		keybd.tp:set_text(self.layouts[layout])

		-- update menu
		for i = 1, #self.layouts do
			local mark = layout == i and style.micon.check or style.micon.blank
			keybd.menu.items[i].right_icon:set_image(mark)
		end
	end

	awesome.connect_signal("xkb::group_changed", self.update)
end

-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:toggle_menu()
	if not self.menu then return end

	if self.menu.wibox.visible then
		self.menu:hide()
	else
		awful.placement.under_mouse(self.menu.wibox)
		awful.placement.no_offscreen(self.menu.wibox)
		self.menu:show({ coords = { x = self.menu.wibox.x, y = self.menu.wibox.y } })
	end
end

-- Toggle layout
-----------------------------------------------------------------------------------------------------------------------
function keybd:toggle(reverse)
	if not self.layouts then return end

	local layout = awesome.xkb_get_layout_group()
	if reverse then
		layout = layout > 0 and (layout - 1) or (#self.layouts - 1)
	else
		layout = layout < (#self.layouts - 1) and (layout + 1) or 0
	end

	awesome.xkb_set_layout_group(layout)
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function keybd.new(style)

	style = style or {}
	if not keybd.menu then keybd:init({}) end

	local widg = svgbox(style.icon or keybd.style.icon)
	widg:set_color(keybd.style.layout_color[1])
	table.insert(keybd.objects, widg)
	keybd.tp:add_to_object(widg)

	keybd.update()
	return widg
end

-- Config metatable to call keybd module as function
-----------------------------------------------------------------------------------------------------------------------
function keybd.mt:__call(...)
	return keybd.new(...)
end

return setmetatable(keybd, keybd.mt)
