-- SafeLuanti Mod Initialization

core.log("action", "[SafeLuanti] Mod loading...")

local modpath = core.get_modpath("safeluanti")
if not modpath then
	core.log("error", "[SafeLuanti] Mod path not found!")
	return
end

local ok, err = pcall(dofile, modpath .. "/moderation.lua")
if not ok then
	core.log("error", "[SafeLuanti] Failed to load moderation.lua: " .. tostring(err))
else
	core.log("action", "[SafeLuanti] Moderation system loaded")
end
