# Launti Game Message Analysis Integration

This document describes how the system receives messages from Launti game, analyzes them for risky content, and notifies parents with action options.

## Overview

The system now supports:
1. **Receiving messages from Launti game** via the moderation API
2. **Analyzing messages** using OpenAI and Perspective AI for risky content
3. **Notifying parents** with clear explanations of why they've been alerted
4. **Parent decision options**: Block, Flag, or Allow

## Backend API Endpoints

### 1. Message Moderation Endpoint
**POST** `/api/moderation/inspect`

Launti game should send messages to this endpoint for analysis.

**Request Body:**
```json
{
  "sender": "username123",
  "message": "Hi, can you send me your address?",
  "childId": 1
}
```

**Response:**
```json
{
  "decision": "FLAG",
  "censor": false,
  "blockSender": false,
  "reason": "Request to share personal information"
}
```

**Decision Types:**
- `ALLOW`: Message is safe, child can continue playing
- `FLAG`: Risky content detected, parent will be notified
- `BLOCK`: Dangerous content, message is blocked immediately

### 2. Get Pending Alerts
**GET** `/api/alerts/pending?childId=1` (optional childId filter)

Returns all alerts waiting for parent decision.

**Response:**
```json
[
  {
    "id": 1,
    "childId": 1,
    "incidentId": 1,
    "sender": "username123",
    "message": "Hi, can you send me your address?",
    "reason": "Request to share personal information",
    "severity": "high",
    "status": "pending",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "parentDecision": null
  }
]
```

### 3. Parent Decision Endpoint
**POST** `/api/alerts/:id/decision`

Parent makes a decision on an alert.

**Request Body:**
```json
{
  "decision": "BLOCK"
}
```

**Decision Options:**
- `BLOCK`: Censors all future messages from this sender to the child
- `FLAG`: Hides the message, reports the user, adds a strike
- `ALLOW`: Allows the child to continue playing, no action taken

**Response:**
```json
{
  "success": true,
  "alert": { ... },
  "message": "Decision \"BLOCK\" applied successfully"
}
```

## Message Analysis

The system analyzes messages for:

1. **Sexual content** - Detected by OpenAI
2. **Hate speech** - Detected by OpenAI
3. **Violence** - Detected by OpenAI
4. **Self-harm content** - Detected by OpenAI
5. **Personal information requests** - Pattern matching for requests to share:
   - Address/location
   - Phone numbers
   - Email addresses
   - School information
   - Meeting requests
6. **Toxic language** - Detected by Perspective AI (toxicity > 0.85)
7. **Threats** - Detected by Perspective AI (threat > 0.70)
8. **Insults** - Detected by Perspective AI (insult > 0.80)

## Parent Actions Explained

### Block
- **What it does**: Censors all future messages from the sender to your child
- **When to use**: When you want to completely prevent this user from contacting your child
- **Effect**: All messages from this user will be automatically blocked

### Flag
- **What it does**: Hides the current message, reports the user, and adds a strike
- **When to use**: When the content is inappropriate but you want to monitor the user
- **Effect**: User gets a strike (3 strikes = auto-block), message is hidden from child

### Allow
- **What it does**: Allows the child to continue playing, no action taken
- **When to use**: When you've reviewed the message and determined it's safe
- **Effect**: No action taken, child can continue normal gameplay

## Setup Instructions

### Backend Setup

1. Install dependencies:
```bash
cd backend
npm install
```

2. Create a `.env` file with your API keys:
```
OPENAI_API_KEY=your_openai_key
PERSPECTIVE_API_KEY=your_perspective_key
```

3. Start the server:
```bash
npm start
```

The server will run on `http://localhost:3000`

### Flutter App Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Update the backend URL in `lib/notifications_screen.dart`:
```dart
final String baseUrl = 'http://YOUR_BACKEND_URL:3000';
```

3. Run the app:
```bash
flutter run
```

## Testing the Integration

### Test Message from Launti

You can test by sending a POST request to the moderation endpoint:

```bash
curl -X POST http://localhost:3000/api/moderation/inspect \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "testuser",
    "message": "Hi, can you send me your address?",
    "childId": 1
  }'
```

This should:
1. Analyze the message
2. Detect the personal information request
3. Create an alert for the parent
4. Return a FLAG decision

### View Alerts in Flutter App

1. Open the notifications screen in the Flutter app
2. You should see the alert with:
   - Child name
   - Sender username
   - Reason for alert
   - Severity level
3. Tap the alert to see options: Block, Flag, Allow

## Architecture

```
Launti Game
    ↓ (POST /api/moderation/inspect)
Backend Moderation Service
    ↓ (Analyzes with OpenAI + Perspective AI)
Policy Engine
    ↓ (Determines risk level)
Incident Service (saves incident)
    ↓
Notification Service (creates alert)
    ↓
Parent receives notification in Flutter app
    ↓ (Parent makes decision)
Alert Decision Endpoint
    ↓
Strike Service (applies block/flag/allow)
```

## Notes

- All data is currently stored in-memory (will be lost on server restart)
- For production, implement a database (MongoDB, PostgreSQL, etc.)
- Consider adding push notifications for real-time alerts
- The system currently blocks users per child (a user blocked for one child can still contact other children)

