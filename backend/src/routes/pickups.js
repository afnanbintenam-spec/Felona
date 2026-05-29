const express = require('express');
const crypto = require('crypto');
const { body, validationResult } = require('express-validator');
const { Op } = require('sequelize');
const { Pickup, User, EcoActivity, Notification } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

// ─── Helper: Create notification ─────────────────────────────
async function createNotification(userId, type, title, message, data = {}) {
  try {
    await Notification.create({ user_id: userId, type, title, message, data });
  } catch (e) {
    console.error('Notification creation failed:', e.message);
  }
}

// ─── Helper: Format pickup response ─────────────────────────
function formatPickup(pickup) {
  const p = pickup.toJSON ? pickup.toJSON() : pickup;
  return {
    id: p.id,
    user_id: p.user_id,
    user_name: p.requester?.full_name || '',
    category: p.waste_category,
    estimated_weight: parseFloat(p.estimated_weight),
    address: p.address,
    latitude: p.latitude ? parseFloat(p.latitude) : null,
    longitude: p.longitude ? parseFloat(p.longitude) : null,
    notes: p.notes,
    status: p.status,
    scheduled_date: p.scheduled_date,
    time_slot: p.time_slot,
    is_recurring: p.is_recurring,
    recurrence_frequency: p.recurrence_frequency,
    recurrence_day: p.recurrence_day,
    recurring_schedule_id: p.recurring_schedule_id,
    collector_id: p.collector_id,
    collector_name: p.collector?.full_name || null,
    collector_phone: p.collector?.phone_number || null,
    collector_photo: p.collector?.profile_picture_url || null,
    collector_rating: p.collector?.avg_rating || null,
    qr_token: p.qr_token,
    eta_minutes: p.eta_minutes,
    collector_latitude: p.collector_latitude ? parseFloat(p.collector_latitude) : null,
    collector_longitude: p.collector_longitude ? parseFloat(p.collector_longitude) : null,
    rating: p.rating ? parseFloat(p.rating) : null,
    feedback: p.feedback,
    accepted_at: p.accepted_at,
    completed_at: p.completed_at,
    eco_points_earned: p.eco_points_earned,
    created_at: p.created_at || p.createdAt,
  };
}

// ─── GET /pickups — user's pickups ───────────────────────────
router.get('/', authenticate, async (req, res) => {
  try {
    const where = req.user.role === 'collector'
      ? { collector_id: req.userId }
      : { user_id: req.userId };

    const pickups = await Pickup.findAll({
      where,
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({ pickups: pickups.map(formatPickup) });
  } catch (error) {
    console.error('Get pickups error:', error);
    res.status(500).json({ error: 'Failed to fetch pickups' });
  }
});

// ─── GET /pickups/available — for collectors ─────────────────
router.get('/available', authenticate, authorize('collector'), async (req, res) => {
  try {
    const pickups = await Pickup.findAll({
      where: { status: 'pending', collector_id: null },
      include: [{ model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] }],
      order: [['created_at', 'DESC']],
    });
    res.json({ pickups: pickups.map(formatPickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch available pickups' });
  }
});

// ─── GET /pickups/active — collector's active job ────────────
router.get('/active', authenticate, authorize('collector'), async (req, res) => {
  try {
    const pickup = await Pickup.findOne({
      where: {
        collector_id: req.userId,
        status: { [Op.in]: ['assigned', 'accepted', 'on_the_way', 'arrived'] },
      },
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
      order: [['updated_at', 'DESC']],
    });

    res.json({ pickup: pickup ? formatPickup(pickup) : null });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch active pickup' });
  }
});

// ─── GET /pickups/history — paginated history ────────────────
router.get('/history', authenticate, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const where = req.user.role === 'collector'
      ? { collector_id: req.userId, status: { [Op.in]: ['completed', 'cancelled'] } }
      : { user_id: req.userId };

    const { count, rows } = await Pickup.findAndCountAll({
      where,
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      pickups: rows.map(formatPickup),
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// ─── GET /pickups/collector/stats — collector dashboard stats ─
router.get('/collector/stats', authenticate, authorize('collector'), async (req, res) => {
  try {
    const jobsCompleted = await Pickup.count({
      where: { collector_id: req.userId, status: 'completed' },
    });

    const totalEarnedResult = await Pickup.sum('eco_points_earned', {
      where: { collector_id: req.userId, status: 'completed' },
    });

    const weightCollected = await Pickup.sum('weight_saved', {
      where: { collector_id: req.userId, status: 'completed' },
    });

    // This week stats
    const weekStart = new Date();
    weekStart.setDate(weekStart.getDate() - weekStart.getDay());
    weekStart.setHours(0, 0, 0, 0);

    const weekJobs = await Pickup.count({
      where: {
        collector_id: req.userId,
        status: 'completed',
        completed_at: { [Op.gte]: weekStart },
      },
    });

    const weekEarnings = await Pickup.sum('eco_points_earned', {
      where: {
        collector_id: req.userId,
        status: 'completed',
        completed_at: { [Op.gte]: weekStart },
      },
    });

    // Average rating
    const ratingResult = await Pickup.findOne({
      attributes: [[require('sequelize').fn('AVG', require('sequelize').col('rating')), 'avg_rating']],
      where: { collector_id: req.userId, rating: { [Op.ne]: null } },
      raw: true,
    });

    res.json({
      jobsCompleted,
      totalEarned: totalEarnedResult || 0,
      weightCollected: parseFloat(weightCollected || 0),
      weekJobs: weekJobs || 0,
      weekEarnings: weekEarnings || 0,
      monthEarnings: totalEarnedResult || 0,
      rating: ratingResult?.avg_rating ? parseFloat(ratingResult.avg_rating) : 0,
    });
  } catch (error) {
    console.error('Collector stats error:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// ─── GET /pickups/:id — single pickup detail ─────────────────
router.get('/:id', authenticate, async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    // Only owner or assigned collector can view
    if (pickup.user_id !== req.userId && pickup.collector_id !== req.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ pickup: formatPickup(pickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch pickup' });
  }
});

// ─── GET /pickups/:id/tracking — live tracking data ──────────
router.get('/:id/tracking', authenticate, async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    res.json({ pickup: formatPickup(pickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tracking data' });
  }
});

// ─── POST /pickups — create pickup with scheduling ───────────
router.post('/', authenticate, [
  body('category').isIn(['plastic', 'metal', 'paper', 'glass', 'electronics', 'organic', 'mixed', 'other']),
  body('estimated_weight').isFloat({ min: 0.1 }),
  body('address').trim().isLength({ min: 10 }),
  body('notes').optional().trim(),
  body('scheduled_date').optional().isISO8601(),
  body('time_slot').optional().trim(),
  body('is_recurring').optional().isBoolean(),
  body('recurrence_frequency').optional().isIn(['weekly', 'biweekly']),
  body('recurrence_day').optional().isInt({ min: 1, max: 7 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Validation failed', details: errors.array() });
    }

    // Generate QR token
    const qrToken = crypto.randomBytes(16).toString('hex');

    // Generate recurring schedule ID if recurring
    const recurringScheduleId = req.body.is_recurring
      ? crypto.randomUUID()
      : null;

    const pickup = await Pickup.create({
      user_id: req.userId,
      waste_category: req.body.category,
      estimated_weight: req.body.estimated_weight,
      address: req.body.address,
      notes: req.body.notes,
      latitude: req.body.latitude,
      longitude: req.body.longitude,
      scheduled_date: req.body.scheduled_date,
      time_slot: req.body.time_slot,
      is_recurring: req.body.is_recurring || false,
      recurrence_frequency: req.body.recurrence_frequency,
      recurrence_day: req.body.recurrence_day,
      recurring_schedule_id: recurringScheduleId,
      qr_token: qrToken,
    });

    // Reload with associations
    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.status(201).json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    console.error('Create pickup error:', error);
    res.status(500).json({ error: 'Failed to create pickup' });
  }
});

// ─── POST /pickups/:id/accept — collector accepts ────────────
router.post('/:id/accept', authenticate, authorize('collector'), async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });
    if (pickup.status !== 'pending') {
      return res.status(400).json({ error: 'Pickup already accepted' });
    }

    await pickup.update({
      collector_id: req.userId,
      status: 'accepted',
      accepted_at: new Date(),
    });

    // Notify requester
    await createNotification(
      pickup.user_id,
      'pickup_accepted',
      'Pickup Accepted! 🎉',
      `A collector has accepted your pickup request.`,
      { pickup_id: pickup.id }
    );

    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to accept pickup' });
  }
});

// ─── PATCH /pickups/:id/status — update status ───────────────
router.patch('/:id/status', authenticate, [
  body('status').isIn(['assigned', 'accepted', 'on_the_way', 'arrived', 'completed', 'cancelled']),
], async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    const newStatus = req.body.status;
    const updates = { status: newStatus };

    // Update ETA if provided
    if (req.body.eta_minutes !== undefined) {
      updates.eta_minutes = req.body.eta_minutes;
    }

    // Update collector location if provided
    if (req.body.collector_latitude) {
      updates.collector_latitude = req.body.collector_latitude;
      updates.collector_longitude = req.body.collector_longitude;
    }

    await pickup.update(updates);

    // Send notification to requester
    const notifMap = {
      on_the_way: { type: 'pickup_on_the_way', title: 'Collector On The Way! 🚛', msg: 'Your collector is heading to you.' },
      arrived: { type: 'pickup_arrived', title: 'Collector Arrived! 📍', msg: 'The collector has arrived at your location.' },
      completed: { type: 'pickup_completed', title: 'Pickup Complete! ✅', msg: 'Your waste has been collected successfully.' },
      cancelled: { type: 'pickup_cancelled', title: 'Pickup Cancelled ❌', msg: 'Your pickup has been cancelled.' },
    };

    if (notifMap[newStatus]) {
      await createNotification(
        pickup.user_id,
        notifMap[newStatus].type,
        notifMap[newStatus].title,
        notifMap[newStatus].msg,
        { pickup_id: pickup.id }
      );
    }

    // Award eco points when completed
    if (newStatus === 'completed') {
      const points = Math.round(parseFloat(pickup.estimated_weight) * 10);
      await pickup.update({
        completed_at: new Date(),
        eco_points_earned: points,
        weight_saved: pickup.estimated_weight,
      });

      const requester = await User.findByPk(pickup.user_id);
      await requester.increment('eco_points', { by: points });

      await EcoActivity.create({
        user_id: pickup.user_id,
        type: 'pickup_completed',
        points,
        description: `🌍 ${pickup.estimated_weight}kg saved from landfill!`,
        metadata: { pickup_id: pickup.id, weight: parseFloat(pickup.estimated_weight) },
      });
    }

    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: 'Failed to update pickup status' });
  }
});

// ─── POST /pickups/:id/complete — mark completed ─────────────
router.post('/:id/complete', authenticate, async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    const points = Math.round(parseFloat(pickup.estimated_weight) * 10);
    await pickup.update({
      status: 'completed',
      completed_at: new Date(),
      eco_points_earned: points,
      weight_saved: pickup.estimated_weight,
    });

    const requester = await User.findByPk(pickup.user_id);
    await requester.increment('eco_points', { by: points });

    await EcoActivity.create({
      user_id: pickup.user_id,
      type: 'pickup_completed',
      points,
      description: `🌍 ${pickup.estimated_weight}kg saved from landfill!`,
      metadata: { pickup_id: pickup.id },
    });

    await createNotification(
      pickup.user_id,
      'pickup_completed',
      'Pickup Complete! ✅',
      `Your waste has been collected. You earned ${points} eco points!`,
      { pickup_id: pickup.id, points }
    );

    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to complete pickup' });
  }
});

// ─── POST /pickups/:id/verify-qr — QR verification ──────────
router.post('/:id/verify-qr', authenticate, [
  body('qr_token').notEmpty(),
], async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    if (pickup.qr_token !== req.body.qr_token) {
      return res.status(400).json({ error: 'Invalid QR code' });
    }

    if (pickup.status === 'completed') {
      return res.status(400).json({ error: 'Pickup already completed' });
    }

    // Mark as completed via QR
    const points = Math.round(parseFloat(pickup.estimated_weight) * 10);
    await pickup.update({
      status: 'completed',
      completed_at: new Date(),
      eco_points_earned: points,
      weight_saved: pickup.estimated_weight,
    });

    const requester = await User.findByPk(pickup.user_id);
    await requester.increment('eco_points', { by: points });

    await EcoActivity.create({
      user_id: pickup.user_id,
      type: 'pickup_completed',
      points,
      description: `🌍 ${pickup.estimated_weight}kg verified & collected!`,
      metadata: { pickup_id: pickup.id, verified_by_qr: true },
    });

    await createNotification(
      pickup.user_id,
      'pickup_completed',
      'Pickup Verified! ✅',
      `QR verified. You earned ${points} eco points!`,
      { pickup_id: pickup.id, points }
    );

    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    res.status(500).json({ error: 'QR verification failed' });
  }
});

// ─── POST /pickups/:id/rate — rate a pickup ──────────────────
router.post('/:id/rate', authenticate, [
  body('rating').isFloat({ min: 1, max: 5 }),
  body('feedback').optional().trim(),
], async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });
    if (pickup.user_id !== req.userId) {
      return res.status(403).json({ error: 'Only the requester can rate' });
    }
    if (pickup.status !== 'completed') {
      return res.status(400).json({ error: 'Can only rate completed pickups' });
    }
    if (pickup.rating) {
      return res.status(400).json({ error: 'Already rated' });
    }

    // Check 30-day window
    const daysSinceCompleted = (Date.now() - new Date(pickup.completed_at).getTime()) / (1000 * 60 * 60 * 24);
    if (daysSinceCompleted > 30) {
      return res.status(400).json({ error: 'Rating window expired (30 days)' });
    }

    await pickup.update({
      rating: req.body.rating,
      feedback: req.body.feedback,
    });

    const fullPickup = await Pickup.findByPk(pickup.id, {
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number', 'profile_picture_url'] },
      ],
    });

    res.json({ pickup: formatPickup(fullPickup) });
  } catch (error) {
    res.status(500).json({ error: 'Failed to rate pickup' });
  }
});

// ─── DELETE /pickups/recurring/:scheduleId — cancel recurring ─
router.delete('/recurring/:scheduleId', authenticate, async (req, res) => {
  try {
    const { scheduleId } = req.params;

    // Cancel all future pending pickups in this schedule
    await Pickup.update(
      { status: 'cancelled' },
      {
        where: {
          recurring_schedule_id: scheduleId,
          user_id: req.userId,
          status: 'pending',
        },
      }
    );

    res.json({ message: 'Recurring schedule cancelled' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to cancel recurring schedule' });
  }
});

// ─── POST /pickups/:id/location — collector updates location ─
router.post('/:id/location', authenticate, authorize('collector'), [
  body('latitude').isFloat(),
  body('longitude').isFloat(),
  body('eta_minutes').optional().isInt({ min: 0 }),
], async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });
    if (pickup.collector_id !== req.userId) {
      return res.status(403).json({ error: 'Not your pickup' });
    }

    await pickup.update({
      collector_latitude: req.body.latitude,
      collector_longitude: req.body.longitude,
      eta_minutes: req.body.eta_minutes,
    });

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update location' });
  }
});

module.exports = router;
