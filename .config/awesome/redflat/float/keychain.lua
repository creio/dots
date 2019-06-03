-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat prefix hotkey manager                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Emacs like key key sequences
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local string = string
local table = table

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local redflat = require("redflat")
local redutil = require("redflat.util")
local redtip = require("redflat.float.hotkeys")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keychain = {}
local tip_cache = {}

local label_pattern = { Mod1 = "A", Mod4 = "M", Control = "C", Shift = "S" }

-- key bindings
keychain.service = { close = { "Escape" }, help = { "F1" }, stepback = { "BackSpace" } }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry        = { width = 220, height = 60 },
		font            = "Sans 14 bold",
		border_width    = 2,
		keytip          = { geometry = { width = 500 }, exit = false },
		color           = { border = "#575757", wibox = "#202020" },
		shape           = nil
	}

	return redflat.util.table.merge(style, redflat.util.table.check(beautiful, "float.keychain") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function build_label(item)
	if #item[1] == 0 then return item[2] end

	local mods = {}
	for _, m in ipairs(item[1]) do mods[#mods + 1] = label_pattern[m] end
	return string.format("%s-%s", table.concat(mods, '-'), item[2])
end

local function build_tip(store, item, prefix)
	prefix = prefix or build_label(item)
	for _, k in ipairs(item[3]) do
		local p = prefix .. " " .. build_label(k)
		if type(k[3]) == "table" then
			build_tip(store, k, p)
		else
			table.insert(store, { {}, p, nil, k[#k] })
		end
	end

	return store
end

local function build_fake_keys(keys)
	local res = {}
	for _, keygroup in ipairs({
		{ description = "Undo last key",       group = "Action", keyname = "stepback" },
		{ description = "Undo sequence",       group = "Action", keyname = "close" },
		{ description = "Show hotkeys helper", group = "Action", keyname = "help" },
	})
	do
		for _, k in ipairs(keys[keygroup.keyname]) do
			table.insert(res, {
				{}, k, nil,
				{ description = keygroup.description, group = keygroup.group }
			})
		end
	end
	return res
end

-- Main widget
-----------------------------------------------------------------------------------------------------------------------

-- Initialize keychain widget
--------------------------------------------------------------------------------
function keychain:init(style)

	-- Init vars
	------------------------------------------------------------
	self.active = nil
	self.parents = {}
	self.sequence = ""

	style = redflat.util.table.merge(default_style(), style or {})
	self.style = style

	-- Wibox
	------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})
	self.wibox:geometry(style.geometry)

	self.label = wibox.widget.textbox()
	self.label:set_align("center")
	self.wibox:set_widget(self.label)

	self.label:set_font(style.font)

	-- Keygrabber
	------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if event == "press" then return false end

		-- dirty fix for first key release
		if self.actkey == key and #mod == 0 then self.actkey = nil; return end

		if awful.util.table.hasitem(self.service.close,    key) then self:hide()
		elseif awful.util.table.hasitem(self.service.stepback, key) then self:undo()
		elseif awful.util.table.hasitem(self.service.help,     key) then redtip:show()
		else
			for _, item in ipairs(self.active[3]) do
				if redutil.key.match_grabber(item, mod, key) then self:activate(item); return end
			end
		end
	end
end

-- Set current key item
--------------------------------------------------------------------------------
function keychain:activate(item, keytip)
	if not self.wibox then self:init() end
	self.actkey = keytip and item[2]

	if type(item[3]) == "function" then
		item[3]()
		self:hide()
	else
		if not self.active then
			redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
			self.wibox.visible = true
			awful.keygrabber.run(self.keygrabber)
		else
			self.parents[#self.parents + 1] = self.active
		end

		self.active = item
		local label = build_label(self.active)
		self.sequence = self.sequence == "" and label or self.sequence .. " " .. label
		self.label:set_text(self.sequence)
	end

	-- build keys helper tip
	if keytip then
		if tip_cache[keytip] then
			self.tip = tip_cache[keytip]
		else
			self.tip = awful.util.table.join(build_tip({}, item), build_fake_keys(self.service))
			tip_cache[keytip] = self.tip
		end
		redtip:set_pack(keytip .. " keychain", self.tip, self.style.keytip.column, self.style.keytip.geometry)
	end
end

-- Deactivate last key item
--------------------------------------------------------------------------------
function keychain:undo()
	if #self.parents > 0 then
		self.sequence = self.sequence:sub(1, - (#build_label(self.active) + 2))
		self.label:set_text(self.sequence)

		self.active = self.parents[#self.parents]
		self.parents[#self.parents] = nil
	else
		self:hide()
	end
end

-- Hide widget
--------------------------------------------------------------------------------
function keychain:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
	self.active = nil
	self.parents = {}
	self.sequence = ""
	redtip:remove_pack()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return keychain
