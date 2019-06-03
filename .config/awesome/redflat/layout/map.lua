-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat map layout                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Tiling with user defined geometry
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local ipairs = ipairs
local pairs = pairs
local math = math
local unpack = unpack or table.unpack

local awful = require("awful")
local timer = require("gears.timer")

local redflat = require("redflat")
local redutil = require("redflat.util")
local common = require("redflat.layout.common")
local rednotify = require("redflat.float.notify")

local hasitem = awful.util.table.hasitem

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local map = { data = setmetatable({}, { __mode = "k" }), scheme = setmetatable({}, { __mode = "k" }), keys = {} }
map.name = "usermap"
map.notification = true
map.notification_style = {}

local hitimer
map.hilight_timeout = 0.2


-- default keys
map.keys.layout = {
	{
		{ "Mod4" }, "s", function() map.swap_group() end,
		{ description = "Change placement direction for group", group = "Layout" }
	},
	{
		{ "Mod4" }, "v", function() map.new_group(true) end,
		{ description = "Create new vertical group", group = "Layout" }
	},
	{
		{ "Mod4" }, "b", function() map.new_group(false) end,
		{ description = "Create new horizontal group", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "v", function() map.insert_group(true) end,
		{ description = "Insert new vertical group before active", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "b", function() map.insert_group(false) end,
		{ description = "Insert new horizontal group before active", group = "Layout" }
	},
	{
		{ "Mod4" }, "d", function() map.delete_group() end,
		{ description = "Destroy group", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "d", function() map.clean_groups() end,
		{ description = "Destroy all empty groups", group = "Layout" }
	},
	{
		{ "Mod4" }, "a", function() map.set_active() end,
		{ description = "Set active group", group = "Layout" }
	},
	{
		{ "Mod4" }, "f", function() map.move_to_active() end,
		{ description = "Move focused client to active group", group = "Layout" }
	},
	{
		{ "Mod4", "Control" }, "a", function() map.hilight_active() end,
		{ description = "Hilight active group", group = "Layout" }
	},
	{
		{ "Mod4" }, ".", function() map.switch_active(1) end,
		{ description = "Activate next group", group = "Layout" }
	},
	{
		{ "Mod4" }, ",", function() map.switch_active(-1) end,
		{ description = "Activate previous group", group = "Layout" }
	},
	{
		{ "Mod4" }, "]", function() map.move_group(1) end,
		{ description = "Move active group to the top", group = "Layout" }
	},
	{
		{ "Mod4" }, "[", function() map.move_group(-1) end,
		{ description = "Move active group to the bottom", group = "Layout" }
	},
	{
		{ "Mod4" }, "r", function() map.reset_tree() end,
		{ description = "Reset layout structure", group = "Layout" }
	},
}

map.keys.resize = {
	{
		{ "Mod4" }, "h", function() map.incfactor(nil, 0.1, false) end,
		{ description = "Increase window horizontal size factor", group = "Resize" }
	},
	{
		{ "Mod4" }, "l", function() map.incfactor(nil, -0.1, false) end,
		{ description = "Decrease window horizontal size factor", group = "Resize" }
	},
	{
		{ "Mod4" }, "k", function() map.incfactor(nil, 0.1, true) end,
		{ description = "Increase window vertical size factor", group = "Resize" }
	},
	{
		{ "Mod4" }, "j", function() map.incfactor(nil, -0.1, true) end,
		{ description = "Decrease window vertical size factor", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "h", function() map.incfactor(nil, 0.1, false, true) end,
		{ description = "Increase group horizontal size factor", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "l", function() map.incfactor(nil, -0.1, false, true) end,
		{ description = "Decrease group horizontal size factor", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "k", function() map.incfactor(nil, 0.1, true, true) end,
		{ description = "Increase group vertical size factor", group = "Resize" }
	},
	{
		{ "Mod4", "Control" }, "j", function() map.incfactor(nil, -0.1, true, true) end,
		{ description = "Decrease group vertical size factor", group = "Resize" }
	},
}


map.keys.all = awful.util.table.join(map.keys.layout, map.keys.resize)

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Layout action notifications
--------------------------------------------------------------------------------
local function notify(txt)
	if map.notification then rednotify:show(redutil.table.merge({ text = txt }, map.notification_style)) end
end

-- Calculate geometry for single client or group
--------------------------------------------------------------------------------
local function cut_geometry(wa, is_vertical, size)
	if is_vertical then
		local g = { x = wa.x, y = wa.y, width = wa.width, height = size }
		wa.y = wa.y + size
		return g
	else
		local g = { x = wa.x, y = wa.y, width = size, height = wa.height }
		wa.x = wa.x + size
		return g
	end
end

-- Build container for single client or group
--------------------------------------------------------------------------------
function map.construct_itempack(cls, wa, is_vertical, parent)
	local pack = { items = {}, wa = wa, cls = { unpack(cls) }, is_vertical = is_vertical, parent = parent }

	-- Create pack of items with base properties
	------------------------------------------------------------
	for i, c in ipairs(cls) do
		pack.items[i] = { client = c, child = nil, factor = 1 }
	end

	-- Update pack clients
	------------------------------------------------------------
	function pack:set_cls(clist)
		local current = { unpack(clist) }

		-- update existing items, remove overage if need
		for i, item in ipairs(self.items) do
			if not item.child then
				if #current > 0 then
					self.items[i].client = current[1]
					table.remove(current, 1)
				else
					self.items[i] = nil
				end
			end
		end

		-- create additional items if need
		for _, c in ipairs(current) do
			self.items[#self.items + 1] = { client = c, child = nil, factor = 1 }
		end
	end

	-- Get current pack clients
	------------------------------------------------------------
	function pack:get_cls()
		local clist = {}
		for _, item in ipairs(self.items) do if not item.child then clist[#clist + 1] = item.client end end
		return clist
	end

	-- Update pack geometry
	------------------------------------------------------------
	function pack:set_wa(workarea)
		self.wa = workarea
	end

	-- Get number of items reserved for single client only
	------------------------------------------------------------
	function pack:get_places()
		local n = 0
		for _, item in ipairs(self.items) do if not item.child then n = n + 1 end end
		return n
	end

	-- Get child index
	------------------------------------------------------------
	function pack:get_child_id(pack_)
		for i, item in ipairs(self.items) do
			if item.child == pack_ then return i end
		end
	end

	-- Check if container with inheritors keep any real client
	------------------------------------------------------------
	function pack:is_filled()
		local filled = false
		for _, item in ipairs(self.items) do
			if not item.child then
				return true
			else
				filled = filled or item.child:is_filled()
			end
		end
		return filled
	end

	-- Increase window size factor for item with index
	------------------------------------------------------------
	function pack:incfacror(index, df, vertical)
		if vertical == self.is_vertical then
			self.items[index].factor = math.max(self.items[index].factor + df, 0.1)
		elseif self.parent then
			local pi = self.parent:get_child_id(self)
			self.parent:incfacror(pi, df, vertical)
		end
	end

	-- Recalculate geometry for every item in container
	------------------------------------------------------------
	function pack:rebuild()
		-- vars
		local geometries = {}
		local weight = 0
		local area = awful.util.table.clone(self.wa)
		local direction = self.is_vertical and "height" or "width"

		-- check factor norming
		for _, item in ipairs(self.items) do
			if not item.child or item.child:is_filled() then weight = weight + item.factor end
		end
		if weight == 0 then return geometries end

		-- geomentry calculation
		for i, item in ipairs(self.items) do
			if not item.child or item.child:is_filled() then
				local size = self.wa[direction] / weight * item.factor
				local g = cut_geometry(area, self.is_vertical, size, i)
				if item.child then
					item.child:set_wa(g)
				else
					geometries[item.client] = g
				end
			end
		end

		return geometries
	end

	return pack
end

-- Build layout tree
--------------------------------------------------------------------------------
local function construct_tree(wa, t)

	-- Initial structure on creation
	------------------------------------------------------------
	local tree = map.scheme[t] and map.scheme[t].construct(wa) or map.base_construct(wa)

	-- Find pack contaner for client
	------------------------------------------------------------
	function tree:get_pack(c)
		for _, pack in ipairs(self.set) do
			for i, item in ipairs(pack.items) do
				if not item.child and c == item.client then return pack, i end
			end
		end
	end

	-- Create new contaner in place of client
	------------------------------------------------------------
	function tree:create_group(c, is_vertical)
		local parent, index = self:get_pack(c)
		local new_pack = map.construct_itempack({}, {}, is_vertical, parent)

		self.set[#self.set + 1] = new_pack
		parent.items[index] = { child = new_pack, factor = 1 }
		self.active = #self.set

		awful.client.setslave(c)
		notify("New " .. (is_vertical and "vertical" or "horizontal") .. " group")
	end

	-- Insert new contaner in before active
	------------------------------------------------------------
	function tree:insert_group(is_vertical)
		local pack = self.set[self.active]
		local new_pack = map.construct_itempack({}, pack.wa, is_vertical, pack.parent)

		if pack.parent then
			for _, item in ipairs(pack.parent.items) do
				if item.child == pack then item.child = new_pack; break end
			end
		end
		new_pack.items[1] = { child = pack, factor = 1, client = nil }

		table.insert(self.set, self.active, new_pack)
		pack.parent = new_pack
		notify("New " .. (is_vertical and "vertical" or "horizontal") .. " group")
	end

	-- Destroy the given container
	------------------------------------------------------------
	function tree:delete_group(pack)
		pack = pack or self.set[self.active]
		local index = hasitem(self.set, pack)
		local has_child = pack:get_places() < #pack.items

		-- some containers can't be destroyed
		-- root container
		if #self.set == 1 then
			notify("Cant't destroy last group")
			return
		end

		-- container with many inheritors
		if has_child and #pack.items > 1 then
			notify("Cant't destroy group with inheritors")
			return
		end

		-- disconnect container from parent
		if pack.parent then
			for i, item in ipairs(pack.parent.items) do
				if item.child == pack then
					if has_child then
						-- container in container case
						-- inheritor can be transmit to parent without changing geometry
						item.child = pack.items[1].child
					else
						-- container without inheritors can be safaly destroyed
						table.remove(pack.parent.items, i)
					end
					break
				end
			end
		end

		-- destroy container
		table.remove(self.set, index)
		if not self.set[self.active] then self.active = #self.set end
		notify("Group " .. tostring(index) .. " destroyed")
	end

	-- Destroy all empty containers
	------------------------------------------------------------
	function tree:cleanup()
		for i = #self.set, 1, -1 do
			if #self.set[i].items == 0 then
				tree:delete_group(self.set[i])
			elseif #self.set[i].items == 1 and self.set[i].items[1].child then
				self.set[i].items[1].child.wa = self.set[i].wa
				tree:delete_group(self.set[i])
			end
		end
	end

	-- Recalculate geometry for whole layout
	------------------------------------------------------------
	function tree:rebuild(clist)
		local current = { unpack(clist) }
		local geometries = {}

		-- distributing clients among existing contaners
		for _, pack in ipairs(self.set) do
			local n = pack:get_places()
			local chunk = { unpack(current, 1, n) }
			current = { unpack(current, n + 1) }
			pack:set_cls(chunk)
		end

		-- distributing clients among existing contaners
		if #current > 0 then
			for _, c in ipairs(current) do
				if self.autoaim then self.active = self:aim() end
				local refill = awful.util.table.join(self.set[self.active]:get_cls(), { c })
				self.set[self.active]:set_cls(refill)
			end
			-- local refill = awful.util.table.join(self.set[self.active]:get_cls(), current)
			-- self.set[self.active]:set_cls(refill)
		end

		-- recalculate geomery for every container in tree
		for _, pack in ipairs(self.set) do
			geometries = awful.util.table.join(geometries, pack:rebuild())
		end

		return geometries
	end

	return tree
end

-- Layout manipulation functions
-----------------------------------------------------------------------------------------------------------------------

-- Change container placement direction
--------------------------------------------------------------------------------
function map.swap_group()
	local c = client.focus
	if not c then return end

	local t = c.screen.selected_tag
	local pack = map.data[t]:get_pack(c)
	pack.is_vertical = not pack.is_vertical
	t:emit_signal("property::layout")
end


-- Create new container for client
--------------------------------------------------------------------------------
function map.new_group(is_vertical)
	local c = client.focus
	if not c then return end

	local t = c.screen.selected_tag
	map.data[t].autoaim = false
	map.data[t]:create_group(c, is_vertical)

	if hitimer then return end

	hitimer = timer({ timeout = map.hilight_timeout })
	hitimer:connect_signal("timeout",
		function()
			redflat.service.navigator.hilight.show(map.data[t].set[map.data[t].active].wa)
			hitimer:stop()
			hitimer = nil
		end
	)
	hitimer:start() -- autostart option doesn't work?
end

-- Destroy active container
--------------------------------------------------------------------------------
function map.delete_group()
	local t = mouse.screen.selected_tag
	map.data[t].autoaim = false
	map.data[t]:delete_group()
	t:emit_signal("property::layout")
end

-- Check if client exist in layout tree
--------------------------------------------------------------------------------
function map.check_client(c)
	if c.sticky then return true end
	for _, t in ipairs(c:tags()) do
		for k, _ in pairs(map.data) do if k == t then return true end end
	end
end

-- Remove client from layout tree and change tree structure
--------------------------------------------------------------------------------
function map.clean_client(c)
	for t, _ in pairs(map.data) do
		local pack, index = map.data[t]:get_pack(c)
		if pack then table.remove(pack.items, index) end
	end
end

-- Destroy all empty containers
--------------------------------------------------------------------------------
function map.clean_groups()
	local t = mouse.screen.selected_tag
	map.data[t].autoaim = false
	map.data[t]:cleanup()
	t:emit_signal("property::layout")
end

-- Set active container (new client will be allocated to this one)
--------------------------------------------------------------------------------
function map.set_active(c)
	c = c or client.focus
	if not c then return end

	local t = c.screen.selected_tag
	local pack = map.data[t]:get_pack(c)
	if pack then
		map.data[t].autoaim = false
		map.data[t].active = hasitem(map.data[t].set, pack)
		redflat.service.navigator.hilight.show(pack.wa)
		notify("Active group index: " .. tostring(map.data[t].active))
	end
end

-- Hilight active container (navigetor widget feature)
--------------------------------------------------------------------------------
function map.hilight_active()
	local t = mouse.screen.selected_tag
	local pack = map.data[t].set[map.data[t].active]
	redflat.service.navigator.hilight.show(pack.wa)
end

-- Switch active container by index
--------------------------------------------------------------------------------
function map.switch_active(n)
	local t = mouse.screen.selected_tag
	local na = map.data[t].active + n
	if map.data[t].set[na] then
		map.data[t].autoaim = false
		map.data[t].active = na
		--local pack = map.data[t].set[na]
		notify("Active group index: " .. tostring(na))
	end
	redflat.service.navigator.hilight.show(map.data[t].set[map.data[t].active].wa)
end

-- Move client to active container
--------------------------------------------------------------------------------
function map.move_to_active(c)
	c = c or client.focus
	if not c then return end

	local t = c.screen.selected_tag
	local pack, index = map.data[t]:get_pack(c)
	if pack then
		table.remove(pack.items, index)
		awful.client.setslave(c)
	end
end

-- Increase window size factor for client
--------------------------------------------------------------------------------
function map.incfactor(c, df, is_vertical, on_group)
	c = c or client.focus
	if not c then return end

	local t = c.screen.selected_tag
	local pack, index = map.data[t]:get_pack(c)
	if not pack then return end -- fix this?

	if on_group and pack.parent then
		index = pack.parent:get_child_id(pack)
		pack = pack.parent
	end

	if pack then
		pack:incfacror(index, df, is_vertical)
		t:emit_signal("property::layout")
	end
end

-- Move element inside his container
--------------------------------------------------------------------------------
function map.move_group(dn)
	local t = mouse.screen.selected_tag
	local pack = map.data[t].set[map.data[t].active]

	if pack.parent then
		map.data[t].autoaim = false
		local i = pack.parent:get_child_id(pack)
		if pack.parent.items[i + dn] then
			pack.parent.items[i], pack.parent.items[i + dn] = pack.parent.items[i + dn], pack.parent.items[i]
			t:emit_signal("property::layout")
		end
	end
end

-- Insert new group before active
--------------------------------------------------------------------------------
function map.insert_group(is_vertical)
	local t = mouse.screen.selected_tag
	map.data[t].autoaim = false
	map.data[t]:insert_group(is_vertical)
	t:emit_signal("property::layout")
end

-- Reset layout structure
--------------------------------------------------------------------------------
function map.reset_tree()
	local t = mouse.screen.selected_tag
	map.data[t] = nil
	t:emit_signal("property::layout")
end


-- Base layout scheme
-----------------------------------------------------------------------------------------------------------------------
-- TODO: fix unused arg
function map.base_set_new_pack(cls, wa, _, parent, factor)
	local pack = map.construct_itempack(cls, wa, true, parent)
	table.insert(parent.items, { child = pack, factor = factor or 1 })
	return pack
end

map.base_autoaim = true

function map.base_aim(tree)
	if #tree.set[2].items == 0 then return 2 end
	local active = #tree.set[3].items > #tree.set[2].items and 2 or 3
	return active
end

function map.base_construct(wa)
	local tree = { set = {}, active = 1, autoaim = map.base_autoaim, aim = map.base_aim }

	tree.set[1] = map.construct_itempack({}, wa, false)
	tree.set[2] = map.base_set_new_pack({}, wa, true, tree.set[1])
	tree.set[3] = map.base_set_new_pack({}, wa, true, tree.set[1])

	return tree
end

-- Tile function
-----------------------------------------------------------------------------------------------------------------------
function map.arrange(p)
	local wa = awful.util.table.clone(p.workarea)
	local cls = p.clients
	local data = map.data
	local t = p.tag or screen[p.screen].selected_tag

	-- nothing to tile here
	if #cls == 0 then return end

	-- init layout tree
	if not data[t] then data[t] = construct_tree(wa, t) end

	-- tile
	p.geometries = data[t]:rebuild(cls)
end


-- Keygrabber
-----------------------------------------------------------------------------------------------------------------------
map.maingrabber = function(mod, key)
	for _, k in ipairs(map.keys.all) do
		if redutil.key.match_grabber(k, mod, key) then k[3](); return true end
	end
end

map.key_handler = function (mod, key, event)
	if event == "press" then return end
	if map.maingrabber(mod, key)             then return end
	if common.grabbers.swap(mod, key, event) then return end
	if common.grabbers.base(mod, key, event) then return end
end


-- Redflat navigator support functions
-----------------------------------------------------------------------------------------------------------------------
function map:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.layout, map.keys.resize) end
	end

	self.tip = awful.util.table.join(self.keys.all, common.keys.swap, common.keys.base, common.keys._fake)
end

function map.startup()
	if not map.tip then map:set_keys() end
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return map
