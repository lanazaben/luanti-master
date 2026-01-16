-- SafeLuanti auto-connect patch

local socket = require("socket") -- LuaSocket
local backend_host = minetest.settings:get("safeluanti_backend_host") or "127.0.0.1"
local backend_port = tonumber(minetest.settings:get("safeluanti_backend_port") or 5050)

-- Function to connect to backend with retry
local function connect_backend()
    local tcp = socket.tcp()
    tcp:settimeout(1) -- 1 second
    local connected = false
    while not connected do
        local success, err = tcp:connect(backend_host, backend_port)
        if success then
            minetest.log("verbose", "[SafeLuanti]: Connected to backend at " .. backend_host .. ":" .. backend_port)
            connected = true
        else
            minetest.log("warning", "[SafeLuanti]: Failed to connect to backend (" .. tostring(err) .. "), retrying in 5s")
            socket.sleep(5)
        end
    end
    return tcp
end

-- Attempt to connect immediately on server start
minetest.register_on_mods_loaded(function()
    minetest.log("verbose", "[SafeLuanti]: Attempting connection to backend...")
    safe_backend_socket = connect_backend()
end)
