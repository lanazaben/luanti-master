const strikes = {};
const blockedUsers = {}; // { username: { childId, blockedAt, reason } }

const MAX_STRIKES = 3;

function addStrike(username) {
  if (!strikes[username]) {
    strikes[username] = 0;
  }

  strikes[username] += 1;

  console.log(`⚠️ Strike added to ${username}: ${strikes[username]}`);

  return strikes[username];
}

function isUserBlocked(username) {
  return strikes[username] >= MAX_STRIKES;
}

function getStrikeCount(username) {
  return strikes[username] || 0;
}

// Parent-initiated blocking (blocks user for specific child)
function blockUserByParent(username, childId, reason) {
  if (!blockedUsers[username]) {
    blockedUsers[username] = {};
  }
  blockedUsers[username][childId] = {
    blockedAt: new Date().toISOString(),
    reason: reason || "Blocked by parent"
  };
  console.log(`🚫 User ${username} blocked by parent for child ${childId}`);
}

// Check if user is blocked by parent for a specific child
function isUserBlockedByParent(username, childId) {
  return blockedUsers[username] && blockedUsers[username][childId] !== undefined;
}

// Remove block (unblock)
function unblockUserByParent(username, childId) {
  if (blockedUsers[username] && blockedUsers[username][childId]) {
    delete blockedUsers[username][childId];
    console.log(`✅ User ${username} unblocked by parent for child ${childId}`);
  }
}

// Flag user (report and hide message, but don't block)
function flagUser(username, childId, reason) {
  addStrike(username);
  console.log(`🚩 User ${username} flagged for child ${childId}: ${reason}`);
  return getStrikeCount(username);
}

module.exports = {
  addStrike,
  isUserBlocked,
  getStrikeCount,
  blockUserByParent,
  isUserBlockedByParent,
  unblockUserByParent,
  flagUser
};
