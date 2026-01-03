const express = require("express");
const router = express.Router();
const { getAlerts, getPendingAlerts, updateAlertDecision, getAlertById } = require("../services/AlertService");
const { updateIncidentDecision, getIncidentById } = require("../services/IncidentService");
const { blockUserByParent, flagUser, unblockUserByParent } = require("../services/StrikeService");
const { getChildById } = require("./children");

/**
 * GET /api/alerts
 * Returns all alerts, optionally filtered by childId
 */
router.get("/", (req, res) => {
  const { childId } = req.query;
  const alerts = getAlerts(childId);
  res.json(alerts);
});

/**
 * GET /api/alerts/pending
 * Returns pending alerts (waiting for parent decision)
 */
router.get("/pending", (req, res) => {
  const { childId } = req.query;
  const alerts = getPendingAlerts(childId);
  res.json(alerts);
});

/**
 * GET /api/alerts/:id
 * Get a specific alert by ID
 */
router.get("/:id", (req, res) => {
  const alert = getAlertById(parseInt(req.params.id));
  if (!alert) {
    return res.status(404).json({ error: "Alert not found" });
  }
  res.json(alert);
});

/**
 * POST /api/alerts/:id/decision
 * Parent makes a decision on an alert
 * Body: { decision: "BLOCK" | "FLAG" | "ALLOW" }
 */
router.post("/:id/decision", async (req, res) => {
  try {
    const { id } = req.params;
    const { decision } = req.body;

    if (!["BLOCK", "FLAG", "ALLOW"].includes(decision)) {
      return res.status(400).json({ error: "Invalid decision. Must be BLOCK, FLAG, or ALLOW" });
    }

    const alert = getAlertById(parseInt(id));
    if (!alert) {
      return res.status(404).json({ error: "Alert not found" });
    }

    // Update alert
    const updatedAlert = updateAlertDecision(parseInt(id), decision);

    // Update incident
    const incident = getIncidentById(alert.incidentId);
    if (incident) {
      updateIncidentDecision(incident.id, decision);
    }

    // Apply parent decision
    if (decision === "BLOCK") {
      // Block the sender for this child
      blockUserByParent(alert.sender, alert.childId, alert.reason);
    } else if (decision === "FLAG") {
      // Flag the user (add strike and report)
      flagUser(alert.sender, alert.childId, alert.reason);
    }
    // ALLOW: No action needed, just allow the message

    res.json({
      success: true,
      alert: updatedAlert,
      message: `Decision "${decision}" applied successfully`
    });

  } catch (err) {
    console.error("Error processing decision:", err);
    res.status(500).json({ error: "Failed to process decision" });
  }
});

/**
 * POST /api/alerts
 * Save a new alert (legacy endpoint, kept for compatibility)
 */
router.post("/", (req, res) => {
  const { player, message, decision, scores } = req.body;

  if (!player || !message || !decision) {
    return res.status(400).json({ error: "Invalid alert data" });
  }

  // This is a legacy endpoint - new alerts are created via NotificationService
  res.status(201).json({ message: "Use moderation endpoint to create alerts" });
});

module.exports = router;
