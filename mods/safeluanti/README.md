# SafeLuanti Mod

This mod integrates Luanti with the SafeLuanti backend moderation system.

## Features

- Intercepts all chat messages
- Sends messages to SafeLuanti backend for analysis
- Blocks inappropriate content based on backend decisions
- Supports parent decisions (BLOCK, FLAG, ALLOW)
- Configurable backend URL

## Configuration

Add to your `minetest.conf` or server settings:

```
safeluanti_backend_url = http://localhost:3000/api/moderation/inspect
```

Default: `http://localhost:3000/api/moderation/inspect`

## Child ID Mapping

The mod needs to know which child ID corresponds to each player. By default, it uses the player name as the child ID.

To set a child ID for a player (admin only):
```
/safeluanti_setchild <player_name> <child_id>
```

## Admin Commands

- `/safeluanti_block <player_name>` - Block a player from chatting
- `/safeluanti_unblock <player_name>` - Unblock a player
- `/safeluanti_setchild <player_name> <child_id>` - Set child ID for a player

## How It Works

1. Player sends a chat message
2. Mod intercepts the message
3. Message is sent to SafeLuanti backend for analysis
4. Backend returns decision: ALLOW, BLOCK, or FLAG
5. Mod acts on the decision:
   - **ALLOW**: Message is sent to all players
   - **BLOCK**: Message is blocked, user is blocked from future messages
   - **FLAG**: Message is hidden, parent is notified via app

## Requirements

- SafeLuanti backend must be running
- HTTP API must be enabled in Luanti
- Backend URL must be accessible from the server

## Notes

- Messages are delayed until backend responds (typically < 1 second)
- If backend is unavailable, messages are allowed (fail-open)
- Blocked users are stored in memory (will reset on server restart)

