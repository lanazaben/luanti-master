function applyPolicy(openai, perspective) {
  const reasons = [];
  
  // Hard parental blocks
  if (openai.categories.sexual) {
    return { action: "FLAG", reason: "Sexual content detected", severity: "high" };
  }
  if (openai.categories.hate) {
    return { action: "FLAG", reason: "Hate speech detected", severity: "high" };
  }
  if (openai.categories.violence) {
    return { action: "FLAG", reason: "Violent content detected", severity: "high" };
  }
  if (openai.categories["self-harm"]) {
    return { action: "FLAG", reason: "Self-harm content detected", severity: "high" };
  }
  if (openai.categories["sexual/minors"]) {
    return { action: "FLAG", reason: "Inappropriate content involving minors detected", severity: "critical" };
  }

  // Check for personal information requests
  const personalInfoPatterns = [
    /(?:send|give|share|tell).*(?:your|ur).*(?:address|location|where.*live|phone|number|email|school|name|age)/i,
    /(?:what|where).*(?:do you|do u|u).*(?:live|go to school|study)/i,
    /(?:meet|visit|come).*(?:you|u).*(?:at|to)/i
  ];
  
  const messageText = openai.input || "";
  if (personalInfoPatterns.some(pattern => pattern.test(messageText))) {
    return { action: "FLAG", reason: "Request to share personal information", severity: "high" };
  }

  // Severe behavioral risk → FLAG
  if (perspective.toxicity > 0.85) {
    return { action: "FLAG", reason: "Highly toxic language detected", severity: "high" };
  }
  if (perspective.threat > 0.70) {
    return { action: "FLAG", reason: "Threatening language detected", severity: "high" };
  }
  if (perspective.insult > 0.80) {
    return { action: "FLAG", reason: "Severe insulting language detected", severity: "medium" };
  }

  // Moderate risk → FLAG
  if (perspective.toxicity > 0.60 || perspective.profanity > 0.60) {
    return { action: "FLAG", reason: "Inappropriate language detected", severity: "medium" };
  }

  // OpenAI flagged but not explicit → FLAG
  if (openai.flagged) {
    return { action: "FLAG", reason: "Content flagged by moderation system", severity: "medium" };
  }

  return { action: "ALLOW", reason: "Safe message", severity: "low" };
}

module.exports = { applyPolicy };
