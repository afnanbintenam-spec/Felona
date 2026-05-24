const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { Listing, User, Offer } = require('../models');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// GET /listings — get all active listings with pagination
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const category = req.query.category;
    const search = req.query.search;

    const where = { status: 'active' };
    if (category) where.category = category;

    if (search) {
      const { Op } = require('sequelize');
      where.title = { [Op.iLike]: `%${search}%` };
    }

    const { count, rows } = await Listing.findAndCountAll({
      where,
      include: [{ model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] }],
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      listings: rows,
      pagination: {
        total: count,
        page,
        pages: Math.ceil(count / limit),
        limit,
      },
    });
  } catch (error) {
    console.error('Get listings error:', error);
    res.status(500).json({ error: 'Failed to fetch listings' });
  }
});

// GET /listings/:id
router.get('/:id', async (req, res) => {
  try {
    const listing = await Listing.findByPk(req.params.id, {
      include: [
        { model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url', 'eco_points'] },
        { model: Offer, as: 'offers', include: [{ model: User, as: 'buyer', attributes: ['id', 'full_name'] }] },
      ],
    });

    if (!listing) return res.status(404).json({ error: 'Listing not found' });

    // Increment views
    await listing.increment('views');

    res.json({ listing });
  } catch (error) {
    console.error('Get listing error:', error);
    res.status(500).json({ error: 'Failed to fetch listing' });
  }
});

// POST /listings — create new listing
router.post('/', authenticate, upload.array('images', 5), [
  body('title').trim().isLength({ min: 3, max: 200 }),
  body('description').trim().isLength({ min: 10 }),
  body('price').isFloat({ min: 0 }),
  body('category').isIn(['plastic', 'metal', 'paper', 'glass', 'electronics', 'textile', 'furniture', 'other']),
  body('condition').optional().isIn(['new', 'like_new', 'good', 'fair', 'poor']),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Validation failed', details: errors.array() });
    }

    const images = req.files ? req.files.map(f => `/uploads/${f.filename}`) : [];

    const listing = await Listing.create({
      user_id: req.userId,
      title: req.body.title,
      description: req.body.description,
      price: req.body.price,
      category: req.body.category,
      condition: req.body.condition || 'good',
      images,
      eco_points_reward: 15,
    });

    // Award eco points for listing
    const { EcoActivity } = require('../models');
    await EcoActivity.create({
      user_id: req.userId,
      type: 'item_listed',
      points: 15,
      description: `Listed "${req.body.title}" — giving it a second life! 💚`,
    });
    await req.user.increment('eco_points', { by: 15 });

    res.status(201).json({ listing });
  } catch (error) {
    console.error('Create listing error:', error);
    res.status(500).json({ error: 'Failed to create listing' });
  }
});

// DELETE /listings/:id
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const listing = await Listing.findByPk(req.params.id);
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    if (listing.user_id !== req.userId) return res.status(403).json({ error: 'Not authorized' });

    await listing.destroy(); // soft delete
    res.json({ message: 'Listing deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete listing' });
  }
});

module.exports = router;
