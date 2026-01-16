-- safeluanti/init.lua
-- Fully mod-safe SafeLuanti loader for Luanti

-- Mod information
local mod_name = "SafeLuanti"
local mod_folder = minetest.get_current_modname()

-- Read backend host/port from minetest.conf
local backend_host = minetest.settings:get("safeluanti_backend_host") or "127.0.0.1"
local backend_port = tonumber(minetest.settings:get("safeluanti_backend_port") or 5050)

-- Log mod loading
minetest.log("action", "[" .. mod_name .. "]: Mod folder loaded: " .. tostring(mod_folder))
minetest.log("action", "[" .. mod_name .. "]: Backend host=" .. backend_host .. ", port=" .. backend_port)

-- This function will be called once mods are loaded
minetest.register_on_mods_loaded(function()
    minetest.log("verbose", "[" .. mod_name .. "]: Mods loaded, SafeLuanti backend should connect via server IPC")
    minetest.log("verbose", "[" .. mod_name .. "]: Check backend logs for actual TCP connection at " .. backend_host .. ":" .. backend_port)
end)

-- Optional: log all chat messages (for testing SafeLuanti alerts)
minetest.register_on_chat_message(function(name, message)
    minetest.log("verbose", "[" .. mod_name .. "]: Chat from " .. name .. ": " .. message)
    -- At this point, the server's SafeLuanti backend can handle the message
    -- No direct TCP connection from Lua is required
end)

-- Optional: log when a player joins
minetest.register_on_joinplayer(function(player)
    minetest.log("verbose", "[" .. mod_name .. "]: Player joined: " .. player:get_player_name())
end)

