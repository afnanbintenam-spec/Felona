const express = require('express');
const { EcoActivity, User, Pickup } = require('../models');
const { authenticate } = require('../middleware/auth');
const sequelize = require('../config/database');

const router = express.Router();

// GET /eco/stats — get user's eco stats
router.get('/stats', authenticate, async (req, res) => {
  try {
    const user = req.user;

    // Total weight recycled
    const weightResult = await Pickup.sum('weight_saved', {
      where: { user_id: req.userId, status: 'recycled' },
    });

    // Items sold count
    const { Listing } = require('../models');
    const itemsSold = await Listing.count({
      where: { user_id: req.userId, status: 'sold' },
    });

    // Pickups completed
    const pickupsCompleted = await Pickup.count({
      where: { user_id: req.userId, status: 'recycled' },
    });

    // CO2 reduced (estimate: 2.5kg CO2 per kg recycled)
    const co2Reduced = (weightResult || 0) * 2.5;

    res.json({
      stats: {
        total_points: user.eco_points,
        eco_level: user.eco_level,
        current_streak: user.current_streak,
        longest_streak: user.longest_streak,
        total_weight_recycled: weightResult || 0,
        items_sold: itemsSold,
        pickups_completed: pickupsCompleted,
        co2_reduced: co2Reduced,
      },
    });
  } catch (error) {
    console.error('Get eco stats error:', error);
    res.status(500).json({ error: 'Failed to fetch eco stats' });
  }
});

// GET /eco/history — get point history
router.get('/history', authenticate, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const { count, rows } = await EcoActivity.findAndCountAll({
      where: { user_id: req.userId },
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      history: rows,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// GET /eco/leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'full_name', 'profile_picture_url', 'eco_points', 'eco_level'],
      order: [['eco_points', 'DESC']],
      limit: 20,
      where: { is_active: true },
    });

    res.json({ leaderboard: users });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

module.exports = router;
