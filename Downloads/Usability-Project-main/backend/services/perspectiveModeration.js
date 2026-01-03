const axios = require("axios");

const PERSPECTIVE_API_KEY = process.env.PERSPECTIVE_API_KEY;
const PERSPECTIVE_URL =
  "https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze";

async function analyzeText(text) {
  const response = await axios.post(
    `${PERSPECTIVE_URL}?key=${PERSPECTIVE_API_KEY}`,
    {
      comment: { text },
      languages: ["en"],
      requestedAttributes: {
        TOXICITY: {},
        INSULT: {},
        PROFANITY: {},
        THREAT: {}
      }
    }
  );

  const scores = response.data.attributeScores;

  return {
    toxicity: scores.TOXICITY.summaryScore.value,
    insult: scores.INSULT.summaryScore.value,
    profanity: scores.PROFANITY.summaryScore.value,
    threat: scores.THREAT.summaryScore.value
  };
}

module.exports = { analyzeText };
