/**
 * Anti-Spam Middleware — Per-user daily action limits.
 *
 * Prevents abuse by limiting specific actions per authenticated user per day.
 *
 * Limits:
 * - create_listing: 10/day
 * - create_pickup: 5/day
 * - make_offer: 15/day
 * - send_message: 200/day
 * - create_order: 10/day
 */

const userActionMap = new Map();
const USER_ACTION_WINDOW_MS = 24 * 60 * 60 * 1000; // 24 hours

const ACTION_LIMITS = {
  create_listing: 10,
  create_pickup: 5,
  make_offer: 15,
  send_message: 200,
  create_order: 10,
};

function antiSpam(actionName) {
  const limit = ACTION_LIMITS[actionName] || 50;

  return (req, res, next) => {
    const userId = req.userId;
    if (!userId) return next();

    const key = `${userId}:${actionName}`;
    const now = Date.now();
    const entry = userActionMap.get(key);

    if (!entry || now - entry.start > USER_ACTION_WINDOW_MS) {
      userActionMap.set(key, { start: now, count: 1 });
      return next();
    }

    entry.count++;
    if (entry.count > limit) {
      return res.status(429).json({
        error: `Daily limit reached. You can only do this ${limit} times per day.`,
        limit,
        action: actionName,
      });
    }
    next();
  };
}

// Clean up stale entries every hour
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of userActionMap) {
    if (now - entry.start > USER_ACTION_WINDOW_MS) {
      userActionMap.delete(key);
    }
  }
}, 60 * 60 * 1000);

module.exports = { antiSpam };
