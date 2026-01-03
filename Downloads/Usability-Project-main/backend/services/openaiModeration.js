const axios = require("axios");

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

async function moderateText(text) {
  const response = await axios.post(
    "https://api.openai.com/v1/moderations",
    {
      model: "omni-moderation-latest",
      input: text
    },
    {
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      }
    }
  );

  return response.data.results[0];
}

module.exports = { moderateText };
