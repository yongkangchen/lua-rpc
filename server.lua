local msg = {
    LOGIN = 0x0001
}

local function msg_request( server, key )
	local v = msg[key:upper()]
	assert(type(v) == "number", key)
	return function(self, ... )
		if self == server then
			return server.send(true, v, ...)
		else
			return server.send(false, v, self, ...)
		end
	end
end

local server = {}
do
	setmetatable(server, {__index = msg_request})

	local listen_tbl = {}
	local wait_tbl = {}
	
	function server.on_msg(t, ...)
		local co = wait_tbl[t]
		if co then
			wait_tbl[t] = nil
			coroutine.resume(co, true, ...)
		else
			local func = listen_tbl[t]
			if func then
				safecall(coroutine.wrap(func), ...)
			else
				LERR("unknow msg, code: 0x%08x", t or 0)
			end
		end
	end

	function server.kill( v )
		v = msg[v:upper()]
		assert(v ~= nil)
		local co = wait_tbl[v]
		assert(co ~= nil)
		wait_tbl[v] = nil
		coroutine.resume(co)
	end

	local function check_result(ok, ...)
		if ok == false then
			error("disconncet")
		elseif ok == nil then
			error("killed")
		end
		return ...
	end

	local function do_wait(t)
		wait_tbl[t] = coroutine.running()
		return check_result(coroutine.yield())
	end

	function server.listen(t, func)
		listen_tbl[t] = func
	end

	function server.wait( t )
		t = msg[t:upper()]
		return do_wait(t)
	end

	function server.send(wait, t, ... )
		SocketManager.send(packer_encode({t, ...}))

		print("send: 0x%08x, %s", t)
		if wait == false then
			return
		end

		return do_wait(t)
	end
end
return server

