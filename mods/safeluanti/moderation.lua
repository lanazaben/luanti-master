-- SafeLuanti Moderation Integration
-- Intercepts chat messages and sends them to the SafeLuanti backend for analysis

local http_client = dofile(core.get_modpath("safeluanti") .. "/http.lua")

-- Track blocked users per child (username -> childId -> blocked)
local blocked_users = {}

-- Child ID mapping: maps player names to child IDs
-- In production, this should be loaded from a database or API
local child_id_map = {}

-- Function to get child ID for a player
local function get_child_id(player_name)
	-- Check if we have a mapping
	if child_id_map[player_name] then
		return child_id_map[player_name]
	end
	
	-- Default: use player name as child ID (for testing)
	-- In production, query the SafeLuanti backend or database
	return player_name
end

-- Function to check if a user is blocked for a specific child
local function is_user_blocked(sender, child_id)
	return blocked_users[sender] and blocked_users[sender][child_id] == true
end

-- Function to block a user for a specific child
local function block_user(sender, child_id)
	if not blocked_users[sender] then
		blocked_users[sender] = {}
	end
	blocked_users[sender][child_id] = true
	core.log("action", string.format("[SafeLuanti] Blocked user %s for child %s", sender, child_id))
end

-- Function to censor a message
local function censor(text)
	return string.rep("█", #text)
end

-- Store pending messages while waiting for moderation response
local pending_messages = {}

-- Register chat message handler
core.register_on_chat_message(function(name, message)
	-- Skip commands (they start with /)
	if message:sub(1, 1) == "/" then
		return false -- Let commands be handled normally
	end

	-- Get child ID for this player
	local child_id = get_child_id(name)
	
	-- Check if sender is already blocked for this child
	if is_user_blocked(name, child_id) then
		core.chat_send_player(
			name,
			core.colorize("#FF5555", "You are blocked from chatting.")
		)
		return true -- Block the message
	end

	-- Store the message details
	local message_id = os.time() .. "_" .. name
	pending_messages[message_id] = {
		sender = name,
		message = message,
		child_id = child_id,
		timestamp = os.time()
	}

	-- Send to moderation backend
	http_client.inspect_message(name, message, child_id, function(decision, data)
		local pending = pending_messages[message_id]
		if not pending then
			return -- Message already handled or expired
		end
		
		pending_messages[message_id] = nil -- Clean up

		if decision == "ALLOW" then
			-- Allow the message - send it to all players
			core.chat_send_all(core.format_chat_message(name, message))
			core.log("action", string.format("[SafeLuanti] Allowed message from %s", name))

		elseif decision == "BLOCK" then
			-- Block the message and user
			block_user(name, child_id)
			core.chat_send_player(
				name,
				core.colorize("#FF0000", "Your message was blocked: " .. (data.reason or "Inappropriate content"))
			)
			core.log("action", string.format("[SafeLuanti] Blocked message from %s: %s", name, data.reason or ""))

		elseif decision == "FLAG" then
			-- Flag the message - hide it from child but don't block user yet
			-- Parent will decide via the app
			core.chat_send_player(
				name,
				core.colorize("#FFAA00", "Your message has been flagged for review. It will not be displayed until approved.")
			)
			core.log("action", string.format("[SafeLuanti] Flagged message from %s: %s", name, data.reason or ""))
			-- Message is not sent to chat - parent will decide via app
		end
	end)

	-- Prevent default chat handling until we get the moderation decision
	-- Note: This means messages will be delayed until backend responds
	-- For better UX, you might want to show a "sending..." indicator
	return true -- Block default chat handling
end)

-- Cleanup old pending messages (older than 30 seconds)
core.register_globalstep(function(dtime)
	local current_time = os.time()
	for msg_id, msg in pairs(pending_messages) do
		if current_time - msg.timestamp > 30 then
			-- Timeout - allow the message (fail-open)
			core.log("warning", string.format("[SafeLuanti] Timeout for message from %s, allowing", msg.sender))
			core.chat_send_all(core.format_chat_message(msg.sender, msg.message))
			pending_messages[msg_id] = nil
		end
	end
end)

-- Admin command to manually block/unblock users
core.register_chatcommand("safeluanti_block", {
	params = "<player_name>",
	description = "Block a player from chatting (admin only)",
	privs = {server = true},
	func = function(name, param)
		local target = param:trim()
		if target == "" then
			return false, "Player name required"
		end
		
		local child_id = get_child_id(target)
		block_user(target, child_id)
		return true, string.format("Blocked %s from chatting", target)
	end,
})

core.register_chatcommand("safeluanti_unblock", {
	params = "<player_name>",
	description = "Unblock a player (admin only)",
	privs = {server = true},
	func = function(name, param)
		local target = param:trim()
		if target == "" then
			return false, "Player name required"
		end
		
		if blocked_users[target] then
			blocked_users[target] = nil
			return true, string.format("Unblocked %s", target)
		else
			return false, string.format("%s is not blocked", target)
		end
	end,
})

-- Command to set child ID mapping (for testing/admin use)
core.register_chatcommand("safeluanti_setchild", {
	params = "<player_name> <child_id>",
	description = "Set child ID for a player (admin only)",
	privs = {server = true},
	func = function(name, param)
		local player_name, child_id = param:match("([^ ]+) (.+)")
		if not player_name or not child_id then
			return false, "Usage: /safeluanti_setchild <player_name> <child_id>"
		end
		
		child_id_map[player_name] = child_id
		return true, string.format("Set child ID for %s to %s", player_name, child_id)
	end,
})

core.log("action", "[SafeLuanti] Moderation mod loaded")
