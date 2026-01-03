// Alert service to manage parent alerts
const alerts = [];

function saveAlert({ childId, incidentId, sender, message, reason, severity, status }) {
  const alert = {
    id: alerts.length + 1,
    childId,
    incidentId,
    sender,
    message,
    reason,
    severity,
    status, // pending | resolved
    createdAt: new Date().toISOString(),
    parentDecision: null // null | "BLOCK" | "FLAG" | "ALLOW"
  };

  alerts.push(alert);
  console.log("📢 Alert created:", alert);

  return alert;
}

function getAlerts(childId = null) {
  if (childId) {
    return alerts.filter(a => a.childId === childId);
  }
  return alerts;
}

function getPendingAlerts(childId = null) {
  const allAlerts = childId ? alerts.filter(a => a.childId === childId) : alerts;
  return allAlerts.filter(a => a.status === "pending");
}

function updateAlertDecision(alertId, parentDecision) {
  const alert = alerts.find(a => a.id === alertId);
  if (alert) {
    alert.parentDecision = parentDecision;
    alert.status = "resolved";
    alert.resolvedAt = new Date().toISOString();
    return alert;
  }
  return null;
}

function getAlertById(alertId) {
  return alerts.find(a => a.id === alertId);
}

module.exports = {
  saveAlert,
  getAlerts,
  getPendingAlerts,
  updateAlertDecision,
  getAlertById
};

