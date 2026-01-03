# Testing Guide for Launti Integration

## Quick Test Steps

### 1. Start the Backend Server

```bash
cd backend
npm install  # If not already done
npm start
```

Server should start on `http://localhost:3000`

### 2. Test Message Moderation

Open a new terminal and test with curl:

```bash
# Test 1: Personal information request (should FLAG)
curl -X POST http://localhost:3000/api/moderation/inspect \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "testuser123",
    "message": "Hi, can you send me your address?",
    "childId": 1
  }'

# Test 2: Safe message (should ALLOW)
curl -X POST http://localhost:3000/api/moderation/inspect \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "friend123",
    "message": "Great game! Want to play again?",
    "childId": 1
  }'
```

### 3. Check Pending Alerts

```bash
curl http://localhost:3000/api/alerts/pending
```

You should see the alert from Test 1.

### 4. Test Parent Decision

Get the alert ID from step 3, then:

```bash
# Block the user
curl -X POST http://localhost:3000/api/alerts/1/decision \
  -H "Content-Type: application/json" \
  -d '{"decision": "BLOCK"}'

# Or Flag the user
curl -X POST http://localhost:3000/api/alerts/1/decision \
  -H "Content-Type: application/json" \
  -d '{"decision": "FLAG"}'

# Or Allow
curl -X POST http://localhost:3000/api/alerts/1/decision \
  -H "Content-Type: application/json" \
  -d '{"decision": "ALLOW"}'
```

### 5. Test Blocked User

After blocking a user, test that their messages are automatically blocked:

```bash
curl -X POST http://localhost:3000/api/moderation/inspect \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "testuser123",
    "message": "Any message",
    "childId": 1
  }'
```

Should return `"decision": "BLOCK"` immediately.

### 6. Test in Flutter App

1. Update `lib/notifications_screen.dart` with your backend URL:
   ```dart
   final String baseUrl = 'http://YOUR_IP:3000'; // Use your computer's IP for mobile testing
   ```

2. Run the Flutter app:
   ```bash
   flutter pub get
   flutter run
   ```

3. Navigate to the Notifications screen
4. You should see pending alerts
5. Tap an alert to see Block/Flag/Allow options
6. Test each decision option

## Expected Behavior

### When a risky message is detected:
1. ✅ Message is analyzed by OpenAI + Perspective AI
2. ✅ Alert is created with clear reason
3. ✅ Parent sees alert in Flutter app
4. ✅ Parent can choose: Block, Flag, or Allow

### When parent chooses BLOCK:
1. ✅ All future messages from that user are blocked
2. ✅ Alert is marked as resolved
3. ✅ User cannot contact the child anymore

### When parent chooses FLAG:
1. ✅ User gets a strike
2. ✅ Message is hidden from child
3. ✅ User is reported
4. ✅ After 3 strikes, user is auto-blocked

### When parent chooses ALLOW:
1. ✅ No action taken
2. ✅ Child can continue playing
3. ✅ Alert is marked as resolved

## Troubleshooting

### Backend not starting?
- Check if port 3000 is available
- Ensure all dependencies are installed: `npm install`
- Check for API keys in `.env` file

### Flutter app not connecting?
- Make sure backend is running
- Check the `baseUrl` in `notifications_screen.dart`
- For mobile testing, use your computer's IP address, not `localhost`
- Check firewall settings

### No alerts showing?
- Make sure you've sent a test message that triggers a FLAG
- Check backend console for errors
- Verify the alert was created: `curl http://localhost:3000/api/alerts/pending`

### API errors?
- Check backend console for detailed error messages
- Verify API keys are set correctly
- Check network connectivity

