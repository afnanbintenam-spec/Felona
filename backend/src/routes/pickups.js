const express = require('express');
const { body, validationResult } = require('express-validator');
const { Pickup, User, EcoActivity } = require('../models');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

// GET /pickups — get user's pickups
router.get('/', authenticate, async (req, res) => {
  try {
    const where = req.user.role === 'collector'
      ? { collector_id: req.userId }
      : { user_id: req.userId };

    const pickups = await Pickup.findAll({
      where,
      include: [
        { model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] },
        { model: User, as: 'collector', attributes: ['id', 'full_name', 'phone_number'] },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({ pickups });
  } catch (error) {
    console.error('Get pickups error:', error);
    res.status(500).json({ error: 'Failed to fetch pickups' });
  }
});

// GET /pickups/available — for collectors
router.get('/available', authenticate, authorize('collector'), async (req, res) => {
  try {
    const pickups = await Pickup.findAll({
      where: { status: 'requested', collector_id: null },
      include: [{ model: User, as: 'requester', attributes: ['id', 'full_name', 'phone_number'] }],
      order: [['created_at', 'DESC']],
    });
    res.json({ pickups });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch available pickups' });
  }
});

// POST /pickups — create pickup request
router.post('/', authenticate, [
  body('waste_category').isIn(['plastic', 'metal', 'paper', 'glass', 'electronics', 'organic', 'mixed', 'other']),
  body('estimated_weight').isFloat({ min: 0.1 }),
  body('address').trim().isLength({ min: 10 }),
  body('notes').optional().trim(),
  body('scheduled_date').optional().isISO8601(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Validation failed', details: errors.array() });
    }

    const pickup = await Pickup.create({
      user_id: req.userId,
      waste_category: req.body.waste_category,
      estimated_weight: req.body.estimated_weight,
      address: req.body.address,
      notes: req.body.notes,
      scheduled_date: req.body.scheduled_date,
      latitude: req.body.latitude,
      longitude: req.body.longitude,
    });

    res.status(201).json({ pickup });
  } catch (error) {
    console.error('Create pickup error:', error);
    res.status(500).json({ error: 'Failed to create pickup' });
  }
});

// PUT /pickups/:id/accept — collector accepts pickup
router.put('/:id/accept', authenticate, authorize('collector'), async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });
    if (pickup.status !== 'requested') return res.status(400).json({ error: 'Pickup already accepted' });

    await pickup.update({ collector_id: req.userId, status: 'accepted' });
    res.json({ pickup });
  } catch (error) {
    res.status(500).json({ error: 'Failed to accept pickup' });
  }
});

// PUT /pickups/:id/status — update pickup status
router.put('/:id/status', authenticate, [
  body('status').isIn(['on_the_way', 'collected', 'recycled', 'cancelled']),
], async (req, res) => {
  try {
    const pickup = await Pickup.findByPk(req.params.id);
    if (!pickup) return res.status(404).json({ error: 'Pickup not found' });

    const newStatus = req.body.status;
    await pickup.update({ status: newStatus });

    // Award eco points when recycled
    if (newStatus === 'recycled') {
      const points = Math.round(pickup.estimated_weight * 10);
      await pickup.update({
        completed_at: new Date(),
        eco_points_earned: points,
        weight_saved: pickup.estimated_weight,
      });

      // Award to requester
      const requester = await User.findByPk(pickup.user_id);
      await requester.increment('eco_points', { by: points });

      await EcoActivity.create({
        user_id: pickup.user_id,
        type: 'pickup_completed',
        points,
        description: `🌍 ${pickup.estimated_weight}kg saved from landfill!`,
        metadata: { pickup_id: pickup.id, weight: pickup.estimated_weight },
      });
    }

    res.json({ pickup });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update pickup status' });
  }
});

module.exports = router;
