-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat focus switch util                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Visual clinet managment helper
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local math = math

local awful = require("awful")
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redflat = require("redflat")
local redutil = require("redflat.util")
local redtip = require("redflat.float.hotkeys")
local rednotify = require("redflat.float.notify")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local navigator = { action = {}, data = {}, active = false }

navigator.ignored = { "dock", "splash", "desktop" }


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		border_width = 2,
		marksize     = { width = 200, height = 100, r = 20 },
		gradstep     = 100,
		linegap      = 35,
		timeout      = 1,
		notify       = {},
		keytip       = { base = { geometry = { width = 600 }, exit = true } },
		titlefont    = { font = "Sans", size = 28, face = 1, slant = 0 },
		num          = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5" },
		font         = { font = "Sans", size = 22, face = 1, slant = 0 },
		color        = { border = "#575757", wibox = "#00000000", bg1 = "#57575740", bg2 = "#57575720",
		                 fbg1 = "#b1222b40", fbg2 = "#b1222b20", mark = "#575757", text = "#202020",
		                 hbg1 = "#32882d40", hbg2 = "#32882d20" },
		shape        = nil
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "service.navigator") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check geometry intersection
--------------------------------------------------------------------------------
local function is_intersect(a, b)
	return (b.x < a.x + a.width and b.x + b.width > a.x and b.y < a.y + a.height and b.y + b.height > a.y)
end

-- Window painting
--------------------------------------------------------------------------------
function navigator.make_paint(c)

	-- Initialize vars
	------------------------------------------------------------
	local style = navigator.style
	local widg = wibox.widget.base.make_widget()

	widg._data = {
		client = c,
		alert = false,
	}

	-- User functions
	------------------------------------------------------------
	function widg:set_client(client_)
		if widg._data.client ~= client_ then
			widg._data.client = client_
			self:emit_signal("widget::redraw_needed")
		end
	end

	function widg:set_alert(value)
		if widg._data.alert ~= value then
			widg._data.alert = value
			self:emit_signal("widget::redraw_needed")
		end
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)

		if not widg._data.client then return end

		-- background
		local bg1, bg2
		local num = math.ceil((width + height) / style.gradstep)

		if widg._data.alert then
			bg1, bg2 = style.color.hbg1, style.color.hbg2
		else
			local is_focused = widg._data.client == client.focus
			bg1 = is_focused and style.color.fbg1 or style.color.bg1
			bg2 = is_focused and style.color.fbg2 or style.color.bg2
		end

		for i = 1, num do
			local cc = i % 2 == 1 and bg1 or bg2
			local l = i * style.gradstep

			cr:set_source(color(cc))
			cr:move_to(0, (i - 1) * style.gradstep)
			cr:rel_line_to(0, style.gradstep)
			cr:rel_line_to(l, - l)
			cr:rel_line_to(- style.gradstep, 0)
			cr:close_path()
			cr:fill()
		end

		-- rounded rectangle on center
		local r = style.marksize.r
		local w, h = style.marksize.width - 2 * r, style.marksize.height - 2 * r

		cr:set_source(color(style.color.mark))
		cr:move_to((width - w) / 2 - r, (height - h) / 2)
		cr:rel_curve_to(0, -r, 0, -r, r, -r)
		cr:rel_line_to(w, 0)
		cr:rel_curve_to(r, 0, r, 0, r, r)
		cr:rel_line_to(0, h)
		cr:rel_curve_to(0, r, 0, r, -r, r)
		cr:rel_line_to(-w, 0)
		cr:rel_curve_to(-r, 0, -r, 0, -r, -r)
		cr:close_path()
		cr:fill()

		-- label
		local index = navigator.style.num[awful.util.table.hasitem(navigator.cls, widg._data.client)]
		local g = redutil.client.fullgeometry(widg._data.client)

		cr:set_source(color(style.color.text))
		redutil.cairo.set_font(cr, style.titlefont)
		redutil.cairo.textcentre.full(cr, { width/2, height/2 - style.linegap / 2 }, index)
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.textcentre.full(cr, { width/2, height/2 + style.linegap / 2 }, g.width .. " x " .. g.height)
	end

	------------------------------------------------------------
	return widg
end

-- Construct wibox
--------------------------------------------------------------------------------
function navigator.make_decor(c)
	local object = {}
	local style = navigator.style

	-- Create wibox
	------------------------------------------------------------
	object.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	object.client = c
	object.widget = navigator.make_paint(c)
	object.wibox:set_widget(object.widget)

	-- User functions
	------------------------------------------------------------
	object.update =  {
		focus = function() object.widget:emit_signal("widget::redraw_needed") end,
		close = function() navigator:restart() end,
		geometry = function() redutil.client.fullgeometry(object.wibox, redutil.client.fullgeometry(object.client)) end
	}

	function object:set_client(client_)
		object.client = client_
		object.widget:set_client(client_)
		redutil.client.fullgeometry(object.wibox, redutil.client.fullgeometry(object.client))

		object.client:connect_signal("focus", object.update.focus)
		object.client:connect_signal("unfocus", object.update.focus)
		object.client:connect_signal("property::geometry", object.update.geometry)
		object.client:connect_signal("unmanage", object.update.close)
	end

	function object:clear(no_hide)
		object.client:disconnect_signal("focus", object.update.focus)
		object.client:disconnect_signal("unfocus", object.update.focus)
		object.client:disconnect_signal("property::geometry", object.update.geometry)
		object.client:disconnect_signal("unmanage", object.update.close)
		object.widget:set_client()
		if not no_hide then object.wibox.visible = false end
	end

	------------------------------------------------------------
	object:set_client(c)
	return object
end


-- Main functions
-----------------------------------------------------------------------------------------------------------------------
function navigator:init()

	-- Style
	------------------------------------------------------------
	self.style = default_style()

	-- Hilight area
	------------------------------------------------------------
	self.hilight = {}

	-- timer
	self.hilight.hidetimer = timer({ timeout = self.style.timeout })
	self.hilight.hidetimer:connect_signal("timeout", function() self.hilight.hide() end)

	-- show/hide
	function self.hilight.show(g)
		for i, c in ipairs(self.cls) do
			self.data[i].widget:set_alert(is_intersect(g, c:geometry()))
		end
		self.hilight.hidetimer:again()
	end

	function self.hilight.hide()
		for i, _ in ipairs(self.cls) do self.data[i].widget:set_alert(false) end
	end

	-- close the navigator on tag switch
	tag.connect_signal('property::selected',
		function()
			if navigator.active then self:close() end
		end
	)

	-- update navigator if new client spawns
	client.connect_signal('manage',
		function()
			if navigator.active then self:restart() end
		end
	)

	-- update navigator if a client gets minimized or restored
	client.connect_signal('property::minimized',
		function()
			if navigator.active then self:restart() end
		end
	)
end

function navigator:run()
	if not self.style then self:init() end

	-- check clients
	local s = mouse.screen
	self.cls = awful.client.tiled(s)

	if #self.cls == 0 or
	   not client.focus or
	   client.focus.fullscreen or
	   awful.util.table.hasitem(navigator.ignored, client.focus.type)
	then
		return
	end

	-- check handler
	local l = awful.layout.get(client.focus.screen)
	local handler = l.key_handler or redflat.layout.common.handler[l]
	if not handler then
		rednotify:show(redutil.table.merge({ text = "Layout not supported" }, self.style.notify))
		return
	end

	-- layout setup if needed
	if l.startup then l.startup() end
	local tip = l.tip or redflat.layout.common.tips[l]

	-- activate navition widgets
	for i, c in ipairs(self.cls) do
		if not self.data[i] then
			self.data[i] = self.make_decor(c)
		else
			self.data[i]:set_client(c)
		end

		self.data[i].wibox.visible = true
	end

	-- run key handler
	self.grabber_settled = handler
	awful.keygrabber.run(self.grabber_settled)

	-- set keys tip
	self.tip_settled = tip
	if tip then
		local tip_style = self.style.keytip[awful.layout.getname(l)] or self.style.keytip.base
		redtip:set_pack(
			"Layout " .. l.name, tip, tip_style.column, tip_style.geometry,
			self.style.keytip.base.exit and function() redflat.layout.common.action.exit() end -- fix this?
		)
	end

	navigator.active = true
end

function navigator:close()
	for i, _ in ipairs(self.cls) do
		self.data[i]:clear()
	end

	awful.keygrabber.stop(self.grabber_settled)
	if self.tip_settled then redtip:remove_pack() end

	local l = client.focus and awful.layout.get(client.focus.screen)
	if l and l.cleanup then l.cleanup() end
	self.cls = {}

	navigator.active = false
end

function navigator:restart()
	-- update decoration
	for i, _ in ipairs(self.cls) do self.data[i]:clear(true) end
	local newcls = awful.client.tiled(mouse.screen)
	for i = 1, math.max(#self.cls, #newcls) do
		if newcls[i] then
			if not self.data[i] then
				self.data[i] = self.make_decor(newcls[i])
			else
				self.data[i]:set_client(newcls[i])
			end

			self.data[i].wibox.visible = true
		else
			self.data[i].wibox.visible = false
		end
	end

	self.cls = newcls
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return navigator
