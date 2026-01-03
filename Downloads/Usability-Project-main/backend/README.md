SafeLuanti Backend
Overview
This backend module implements AI-powered chat moderation for the SafeLuanti system. It acts as an intermediary between the Luanti game server and the SafeLuanti mobile application.
Responsibilities
Receive chat messages from the Luanti server
Analyze content using AI moderation APIs
Apply moderation policies
Expose REST APIs for the mobile application
Generate alerts for parents
Technologies
Node.js
Express.js
OpenAI Moderation API
Google Perspective API (optional extension)
Key Endpoints
POST /api/moderation/chat
Receives a chat message and returns a moderation decision.
GET /api/alerts
Returns moderation alerts for parents.
GET /api/children
Returns linked child profiles.
Security Notes
No passwords are transmitted or stored
API keys are stored in environment variables
Only trusted game servers can submit chat messages