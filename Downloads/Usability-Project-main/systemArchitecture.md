SafeLuanti System Architecture
SafeLuanti follows a layered, distributed architecture designed to separate concerns between gameplay, moderation logic, and parental monitoring.
1. Luanti Game Layer
   The Luanti game server is extended using a custom Lua mod. This mod intercepts player chat messages after authentication and forwards them securely to the SafeLuanti backend using HTTP. The mod does not store credentials or perform analysis locally.
2. Backend Moderation Layer
   The backend server acts as the central processing unit of the system. It receives chat messages from the game server, analyzes them using third-party AI moderation services (OpenAI Moderation API and Google Perspective API), and applies a policy engine to determine whether messages should be allowed, flagged, or blocked. This layer is also responsible for storing alerts and exposing APIs to the mobile application.
3. Mobile Application Layer
   The SafeLuanti mobile application provides parents with an intuitive interface to monitor alerts, manage child profiles, and receive notifications. The application does not process chat content or interact directly with the game. Instead, it consumes secure backend APIs, ensuring privacy and scalability.
   Data Flow
   Luanti → Backend → AI Services → Backend → Mobile App
   This architecture ensures security, modularity, and clear separation of responsibilities while enabling real-time moderation and parental awareness.