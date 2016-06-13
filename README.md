# lua-rpc

## You should implement your own:
```lua
SocketManager.send(packer_encode({t, ...}))
```
And somewhere call `server.on_msg`

## Async Usage
```lua
local server = require "server"
server.listen(0x0001, function(ret)
  print("login ret", ret)
end)
server.login("username", "password")
```


## Sync Usage
```lua
coroutine.wrap(function()
  local ret = server:login("username", "password")
  print("login ret", ret)
end)()
```
