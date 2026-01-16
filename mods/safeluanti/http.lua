-- IPC client for SafeLuanti backend integration
-- Uses LOCAL TCP socket (NO HTTP inside Luanti)

local socket = require("socket")

local SAFE_LUANTI_HOST = core.settings:get("safeluanti_backend_host") or "127.0.0.1"
local SAFE_LUANTI_PORT = tonumber(core.settings:get("safeluanti_backend_port")) or 5050

local function inspect_message(sender, message, child_id, callback)
	-- Prepare payload
	local payload = {
		sender = sender,
		message = message,
		childId = child_id
	}

	local json_payload = core.write_json(payload)
	if not json_payload then
		core.log("error", "[SafeLuanti] Failed to serialize payload")
		callback("ALLOW")
		return
	end

	-- Create TCP client
	local client = socket.tcp()
	client:settimeout(1)

	local ok, err = client:connect(SAFE_LUANTI_HOST, SAFE_LUANTI_PORT)
	if not ok then
		core.log("warning", "[SafeLuanti] Backend connection failed: " .. tostring(err))
		callback("ALLOW") -- fail-open
		return
	end

	-- Send message
	client:send(json_payload .. "\n")

	-- Receive response
	local response, recv_err = client:receive("*l")
	client:close()

	if not response then
		core.log("warning", "[SafeLuanti] No response from backend: " .. tostring(recv_err))
		callback("ALLOW")
		return
	end

	-- Parse response
	local data = core.parse_json(response)
	if not data then
		core.log("warning", "[SafeLuanti] Failed to parse backend response: " .. response)
		callback("ALLOW")
		return
	end

	local decision = data.decision or "ALLOW"

	core.log("action", string.format(
		"[SafeLuanti] Message from %s: decision=%s, reason=%s",
		sender,
		decision,
		data.reason or "none"
	))

	callback(decision, data)
end

return {
	inspect_message = inspect_message
}
