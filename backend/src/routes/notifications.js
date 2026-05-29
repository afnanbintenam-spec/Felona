const express = require('express');
const { Notification } = require('../models');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /notifications — get user's notifications
router.get('/', authenticate, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 30;
    const offset = (page - 1) * limit;

    const { count, rows } = await Notification.findAndCountAll({
      where: { user_id: req.userId },
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    const unreadCount = await Notification.count({
      where: { user_id: req.userId, is_read: false },
    });

    res.json({
      notifications: rows,
      unread_count: unreadCount,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// POST /notifications/read — mark notifications as read
router.post('/read', authenticate, async (req, res) => {
  try {
    const { notification_ids } = req.body;

    if (notification_ids && Array.isArray(notification_ids)) {
      await Notification.update(
        { is_read: true, read_at: new Date() },
        { where: { id: notification_ids, user_id: req.userId } }
      );
    } else {
      // Mark all as read
      await Notification.update(
        { is_read: true, read_at: new Date() },
        { where: { user_id: req.userId, is_read: false } }
      );
    }

    res.json({ message: 'Notifications marked as read' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to mark notifications' });
  }
});

// DELETE /notifications/:id
router.delete('/:id', authenticate, async (req, res) => {
  try {
    await Notification.destroy({
      where: { id: req.params.id, user_id: req.userId },
    });
    res.json({ message: 'Notification deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});

module.exports = router;
