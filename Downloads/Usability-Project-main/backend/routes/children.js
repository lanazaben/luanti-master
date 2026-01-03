const express = require("express");
const router = express.Router();

// Temporary in-memory storage
const children = [];

/**
 * POST /api/children
 * Link a child account
 */
router.post("/", (req, res) => {
  const { name, username, age, parent } = req.body;

  if (!name || !username || !age) {
    return res.status(400).json({ error: "Invalid child data" });
  }

  const child = {
    id: Date.now(),
    name,
    username,
    age,
    parent,
    createdAt: new Date()
  };

  children.push(child);
  res.status(201).json(child);
});

/**
 * GET /api/children
 * Get all linked children
 */
router.get("/", (req, res) => {
  res.json(children);
});

/**
 * GET /api/children/:id
 * Get a specific child by ID
 */
router.get("/:id", (req, res) => {
  const child = children.find(c => c.id === parseInt(req.params.id));
  if (!child) {
    return res.status(404).json({ error: "Child not found" });
  }
  res.json(child);
});

function getChildById(childId) {
  return children.find(c => c.id === parseInt(childId) || c.id === childId);
}

function getChildName(childId) {
  const child = getChildById(childId);
  return child ? child.name : "Your child";
}

module.exports = { router, getChildById, getChildName };
