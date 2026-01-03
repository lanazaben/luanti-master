const incidents = [];

function saveIncident({ sender, childId, message, decision, reason, severity, openaiResult, perspectiveResult }) {
  const incident = {
    id: incidents.length + 1,
    sender,
    childId,
    message,
    decision,
    reason: reason || "Content flagged by moderation system",
    severity: severity || "medium",
    openaiResult,
    perspectiveResult,
    parentDecision: null, // null | "BLOCK" | "FLAG" | "ALLOW"
    timestamp: new Date().toISOString()
  };

  incidents.push(incident);
  console.log("📁 Incident saved:", incident);

  return incident;
}

function getIncidentsByChild(childId) {
  return incidents.filter(i => i.childId === childId);
}

function getPendingIncidents(childId) {
  return incidents.filter(i => i.childId === childId && i.parentDecision === null);
}

function updateIncidentDecision(incidentId, parentDecision) {
  const incident = incidents.find(i => i.id === incidentId);
  if (incident) {
    incident.parentDecision = parentDecision;
    incident.parentDecisionTimestamp = new Date().toISOString();
    return incident;
  }
  return null;
}

function getIncidentById(incidentId) {
  return incidents.find(i => i.id === incidentId);
}

module.exports = {
  saveIncident,
  getIncidentsByChild,
  getPendingIncidents,
  updateIncidentDecision,
  getIncidentById
};
