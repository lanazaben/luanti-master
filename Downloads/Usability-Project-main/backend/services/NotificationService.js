const { saveAlert } = require("./AlertService");

function notifyParent(childId, incident) {
  // Create an alert for the parent
  const alert = saveAlert({
    childId,
    incidentId: incident.id,
    sender: incident.sender,
    message: incident.message,
    reason: incident.reason,
    severity: incident.severity,
    status: "pending" // pending | resolved
  });

  console.log("📣 Parent notified");
  console.log({
    childId,
    incidentId: incident.id,
    message: incident.message,
    sender: incident.sender,
    reason: incident.reason
  });

  return alert;
}

module.exports = {
  notifyParent
};
