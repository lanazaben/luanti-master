const express = require("express");
const router = express.Router();

const { saveIncident } = require("../services/IncidentService");
const { addStrike, isUserBlocked } = require("../services/StrikeService");
const { notifyParent } = require("../services/NotificationService");

const { moderateText } = require("../services/openaiModeration");
const { analyzeText } = require("../services/perspectiveModeration");
const { applyPolicy } = require("../policyEngine");

// POST /api/moderation/inspect
// Endpoint for Launti game to send messages for moderation
router.post("/inspect", async (req, res) => {
  try {
    const { sender, message, childId } = req.body;

    if (!sender || !message || !childId) {
      return res.status(400).json({ error: "Missing required fields: sender, message, childId" });
    }

    // Check if sender is already blocked by parent
    const { isUserBlockedByParent } = require("../services/StrikeService");
    if (isUserBlockedByParent(sender, childId)) {
      return res.json({
        decision: "BLOCK",
        censor: true,
        blockSender: true,
        reason: "User blocked by parent"
      });
    }

    // 1️⃣ Run OpenAI moderation
    const openaiResult = await moderateText(message);

    // 2️⃣ Run Perspective AI
    const perspectiveResult = await analyzeText(message);

    // 3️⃣ Apply unified policy
    const policyResult = applyPolicy({ ...openaiResult, input: message }, perspectiveResult);
    const decision = policyResult.action;

    // 4️⃣ FLAG → save incident, notify parent (wait for parent decision)
    if (decision === "FLAG") {
      const incident = saveIncident({
        sender,
        childId,
        message,
        decision: "FLAG",
        reason: policyResult.reason,
        severity: policyResult.severity,
        openaiResult,
        perspectiveResult
      });

      notifyParent(childId, incident);
      
      // Return FLAG decision to Launti - message should be held until parent decides
      return res.json({
        decision: "FLAG",
        censor: false, // Don't auto-censor, wait for parent
        blockSender: false,
        reason: policyResult.reason
      });
    }

    // 5️⃣ ALLOW → safe message, child can continue
    res.json({
      decision: "ALLOW",
      censor: false,
      blockSender: false
    });

  } catch (err) {
    console.error("Moderation error:", err);
    res.status(500).json({ error: "Moderation failed" });
  }
});

module.exports = router;
