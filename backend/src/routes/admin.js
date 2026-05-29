const express = require('express');
const { Op } = require('sequelize');
const sequelize = require('../config/database');
const { User, Pickup, Listing, EcoActivity, Notification } = require('../models');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// ─── Admin middleware ─────────────────────────────────────────
// For now, admin is identified by a special role or env-based check
const authorizeAdmin = (req, res, next) => {
  // Check if user has admin role or is in admin list
  const adminEmails = (process.env.ADMIN_EMAILS || '').split(',').map(e => e.trim());
  if (req.user.role !== 'admin' && !adminEmails.includes(req.user.email)) {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// ─── GET /admin/dashboard — overview stats ───────────────────
router.get('/dashboard', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const totalUsers = await User.count({ where: { is_active: true } });
    const totalCollectors = await User.count({ where: { role: 'collector', is_active: true } });
    const totalPickups = await Pickup.count();
    const completedPickups = await Pickup.count({ where: { status: 'completed' } });
    const pendingPickups = await Pickup.count({ where: { status: 'pending' } });
    const activePickups = await Pickup.count({
      where: { status: { [Op.in]: ['assigned', 'accepted', 'on_the_way', 'arrived'] } },
    });
    const totalListings = await Listing.count();
    const activeListings = await Listing.count({ where: { status: 'active' } });

    const totalWeightSaved = await Pickup.sum('weight_saved', {
      where: { status: 'completed' },
    });

    const totalEcoPoints = await User.sum('eco_points');

    // This week stats
    const weekStart = new Date();
    weekStart.setDate(weekStart.getDate() - 7);

    const newUsersThisWeek = await User.count({
      where: { created_at: { [Op.gte]: weekStart } },
    });

    const pickupsThisWeek = await Pickup.count({
      where: { created_at: { [Op.gte]: weekStart } },
    });

    res.json({
      stats: {
        users: { total: totalUsers, collectors: totalCollectors, new_this_week: newUsersThisWeek },
        pickups: {
          total: totalPickups,
          completed: completedPickups,
          pending: pendingPickups,
          active: activePickups,
          this_week: pickupsThisWeek,
        },
        listings: { total: totalListings, active: activeListings },
        impact: {
          total_weight_saved: parseFloat(totalWeightSaved || 0),
          co2_reduced: parseFloat(totalWeightSaved || 0) * 2.5,
          total_eco_points: totalEcoPoints || 0,
        },
      },
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard stats' });
  }
});

// ─── GET /admin/users — list all users ───────────────────────
router.get('/users', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;
    const role = req.query.role;
    const search = req.query.search;

    const where = {};
    if (role) where.role = role;
    if (search) {
      where[Op.or] = [
        { full_name: { [Op.iLike]: `%${search}%` } },
        { email: { [Op.iLike]: `%${search}%` } },
      ];
    }

    const { count, rows } = await User.findAndCountAll({
      where,
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      users: rows,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// ─── PATCH /admin/users/:id — update user (ban/role change) ──
router.patch('/users/:id', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });

    const updates = {};
    if (req.body.is_active !== undefined) updates.is_active = req.body.is_active;
    if (req.body.role) updates.role = req.body.role;

    await user.update(updates);
    res.json({ user: user.toJSON() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// ─── GET /admin/pickups — all pickups with filters ───────────
router.get('/pickups', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;
    const status = req.query.status;

    const where = {};
    if (status) where.status = status;

    const { count, rows } = await Pickup.findAndCountAll({
      where,
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'email'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'email'] },
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      pickups: rows,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch pickups' });
  }
});

// ─── POST /admin/pickups/:id/assign — assign collector ───────
router.post('/pickups/:id/assign', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const { collector_id } = req.body;
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    const collector = await User.findByPk(collector_id);
    if (!collector || collector.role !== 'collector') {
      return res.status(400).json({ error: 'Invalid collector' });
    }

    await pickup.update({
      collector_id,
      status: 'assigned',
    });

    // Notify collector
    await Notification.create({
      user_id: collector_id,
      type: 'pickup_assigned',
      title: 'New Pickup Assigned! 📦',
      message: `You have been assigned a new pickup at ${pickup.address}`,
      data: { pickup_id: pickup.id },
    });

    // Notify requester
    await Notification.create({
      user_id: pickup.user_id,
      type: 'pickup_assigned',
      title: 'Collector Assigned! 🎉',
      message: `A collector has been assigned to your pickup.`,
      data: { pickup_id: pickup.id },
    });

    res.json({ message: 'Collector assigned', pickup });
  } catch (error) {
    res.status(500).json({ error: 'Failed to assign collector' });
  }
});

// ─── GET /admin/listings — all listings ──────────────────────
router.get('/listings', authenticate, authorizeAdmin, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;

    const { count, rows } = await Listing.findAndCountAll({
      include: [{ model: User, as: 'seller', attributes: ['id', 'full_name', 'email'] }],
      order: [['created_at', 'DESC']],
      limit,
      offset,
      paranoid: false, // include soft-deleted
    });

    res.json({
      listings: rows,
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch listings' });
  }
});

// ─── DELETE /admin/listings/:id — remove listing ─────────────
router.delete('/listings/:id', authenticate, authorizeAdmin, async (req, res) => {
  try {
    await Listing.destroy({ where: { id: req.params.id }, force: true });
    res.json({ message: 'Listing removed' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to remove listing' });
  }
});

// ─── GET /admin/analytics — detailed analytics ──────────────
router.get('/analytics', authenticate, authorizeAdmin, async (req, res) => {
  try {
    // Pickups per day (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const pickupsPerDay = await Pickup.findAll({
      attributes: [
        [sequelize.fn('DATE', sequelize.col('created_at')), 'date'],
        [sequelize.fn('COUNT', '*'), 'count'],
      ],
      where: { created_at: { [Op.gte]: thirtyDaysAgo } },
      group: [sequelize.fn('DATE', sequelize.col('created_at'))],
      order: [[sequelize.fn('DATE', sequelize.col('created_at')), 'ASC']],
      raw: true,
    });

    // Waste categories breakdown
    const categoryBreakdown = await Pickup.findAll({
      attributes: [
        'waste_category',
        [sequelize.fn('COUNT', '*'), 'count'],
        [sequelize.fn('SUM', sequelize.col('estimated_weight')), 'total_weight'],
      ],
      where: { status: 'completed' },
      group: ['waste_category'],
      raw: true,
    });

    // Top collectors
    const topCollectors = await Pickup.findAll({
      attributes: [
        'collector_id',
        [sequelize.fn('COUNT', '*'), 'jobs_completed'],
        [sequelize.fn('SUM', sequelize.col('weight_saved')), 'total_weight'],
        [sequelize.fn('AVG', sequelize.col('rating')), 'avg_rating'],
      ],
      where: { status: 'completed', collector_id: { [Op.ne]: null } },
      group: ['collector_id'],
      order: [[sequelize.fn('COUNT', '*'), 'DESC']],
      limit: 10,
      raw: true,
    });

    // Enrich with user names
    const collectorIds = topCollectors.map(c => c.collector_id);
    const collectors = await User.findAll({
      where: { id: collectorIds },
      attributes: ['id', 'full_name', 'profile_picture_url'],
    });
    const collectorMap = {};
    collectors.forEach(c => { collectorMap[c.id] = c; });

    const enrichedCollectors = topCollectors.map(c => ({
      ...c,
      name: collectorMap[c.collector_id]?.full_name || 'Unknown',
      photo: collectorMap[c.collector_id]?.profile_picture_url,
    }));

    res.json({
      pickups_per_day: pickupsPerDay,
      category_breakdown: categoryBreakdown,
      top_collectors: enrichedCollectors,
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

module.exports = router;
