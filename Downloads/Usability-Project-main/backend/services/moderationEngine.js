const decideAction = (scores) => {
  const toxicity = scores.TOXICITY.summaryScore.value;

  if (toxicity < 0.3) {
    return { action: "ALLOW", reason: "Safe message" };
  }

  if (toxicity < 0.7) {
    return { action: "WARN", reason: "Potentially harmful language" };
  }

  return { action: "BLOCK", reason: "Toxic content detected" };
};

module.exports = { decideAction };
