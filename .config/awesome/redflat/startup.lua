-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat startup check                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Save exit reason to file
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local io = io

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local startup = { locked = false }

startup.path = "/tmp/awesome-exit-reason"
--startup.bin  = "awesome-client"

local REASON = { RESTART = "restart", EXIT =  "exit" }

-- Stamp functions
-----------------------------------------------------------------------------------------------------------------------

-- save restart reason
function startup.stamp(reason_restart)
	local file = io.open(startup.path, "w")
	file:write(reason_restart)
	file:close()
end

function startup:activate()
	-- check if it is first start
	local reason = redutil.read.file(startup.path)
	self.is_startup = (not reason or reason == REASON.EXIT) and not self.locked

	-- save reason on exit
	awesome.connect_signal("exit",
	   function(is_restart) startup.stamp(is_restart and REASON.RESTART or REASON.EXIT) end
	)
end

-----------------------------------------------------------------------------------------------------------------------
return startup
