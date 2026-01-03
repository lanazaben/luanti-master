require("dotenv").config();

const express = require("express");
const cors = require("cors");

const moderationRoutes = require("./routes/moderation");
const alertRoutes = require("./routes/alerts");
const { router: childRoutes } = require("./routes/children");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/moderation", moderationRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/children", childRoutes);

app.listen(3000, () => {
  console.log("SafeLuanti backend running on port 3000");
});
