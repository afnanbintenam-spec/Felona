const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { Listing, User, Offer, EcoActivity } = require('../models');
const { authenticate } = require('../middleware/auth');
const { antiSpam } = require('../middleware/antiSpam');
const upload = require('../middleware/upload');

const router = express.Router();

// ─── Helper: Serialize listing to Flutter-compatible shape ────
function formatListing(listing) {
  const l = listing.toJSON ? listing.toJSON() : listing;
  return {
    id: l.id,
    title: l.title,
    description: l.description,
    price: parseFloat(l.price),          // DECIMAL comes as string from pg — cast to number
    category: l.category,
    condition: l.condition,
    image_urls: l.images || [],          // DB field is 'images', Flutter expects 'image_urls'
    seller_id: l.user_id,                // DB field is 'user_id', Flutter expects 'seller_id'
    seller_name: l.seller?.full_name || '',
    seller_avatar_url: l.seller?.profile_picture_url || null,
    status: l.status,
    location: l.location || null,
    views: l.views,
    eco_points_reward: l.eco_points_reward,
    is_favorite: false,                  // Per-user favorites not yet stored server-side
    created_at: l.created_at || l.createdAt,
    updated_at: l.updated_at || l.updatedAt,
  };
}

// GET /listings/my — authenticated user's own listings
router.get('/my', authenticate, async (req, res) => {
  try {
    const listings = await Listing.findAll({
      where: { user_id: req.userId },
      include: [{ model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] }],
      order: [['created_at', 'DESC']],
    });

    res.json({ listings: listings.map(formatListing) });
  } catch (error) {
    console.error('Get my listings error:', error);
    res.status(500).json({ error: 'Failed to fetch your listings' });
  }
});

// GET /listings/search?q=... — search listings by title
router.get('/search', async (req, res) => {
  try {
    const searchQuery = req.query.q || req.query.search || '';
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const { Op } = require('sequelize');
    const where = {
      status: 'active',
      title: { [Op.iLike]: `%${searchQuery}%` },
    };

    const { count, rows } = await Listing.findAndCountAll({
      where,
      include: [{ model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] }],
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      listings: rows.map(formatListing),
      pagination: { total: count, page, pages: Math.ceil(count / limit) },
    });
  } catch (error) {
    console.error('Search listings error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});

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
      listings: rows.map(formatListing),
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

    res.json({ listing: formatListing(listing) });
  } catch (error) {
    console.error('Get listing error:', error);
    res.status(500).json({ error: 'Failed to fetch listing' });
  }
});

// POST /listings — create new listing
router.post('/', authenticate, antiSpam('create_listing'), upload.array('images', 5), [
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

    // Reload with seller data so formatListing can include seller info
    const fullListing = await Listing.findByPk(listing.id, {
      include: [{ model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] }],
    });

    res.status(201).json({ listing: formatListing(fullListing) });
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

// POST /listings/:id/favorite — toggle favorite (client-side only, stored in response)
// Backend acknowledges the toggle; actual persistence is on the client
router.post('/:id/favorite', authenticate, async (req, res) => {
  try {
    const listing = await Listing.findByPk(req.params.id);
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    res.json({ message: 'Favorite toggled', listing_id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to toggle favorite' });
  }
});

// POST /listings/:id/offer — buyer makes an offer
router.post('/:id/offer', authenticate, antiSpam('make_offer'), [
  body('amount').isFloat({ min: 0 }),
  body('message').optional().trim().isLength({ max: 500 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Validation failed', details: errors.array() });
    }

    const listing = await Listing.findByPk(req.params.id);
    if (!listing) return res.status(404).json({ error: 'Listing not found' });
    if (listing.status !== 'active') return res.status(400).json({ error: 'Listing is no longer active' });
    if (listing.user_id === req.userId) return res.status(400).json({ error: 'Cannot make an offer on your own listing' });

    const offer = await Offer.create({
      listing_id: req.params.id,
      buyer_id: req.userId,
      amount: req.body.amount,
      message: req.body.message,
    });

    res.status(201).json({ offer });
  } catch (error) {
    console.error('Make offer error:', error);
    res.status(500).json({ error: 'Failed to make offer' });
  }
});

// GET /listings/offers/my — buyer's own offers
router.get('/offers/my', authenticate, async (req, res) => {
  try {
    const offers = await Offer.findAll({
      where: { buyer_id: req.userId },
      include: [{ model: Listing, as: 'listing', attributes: ['id', 'title', 'images', 'price', 'status'] }],
      order: [['created_at', 'DESC']],
    });

    const formatted = offers.map(o => {
      const obj = o.toJSON();
      return {
        ...obj,
        amount: parseFloat(obj.amount),
        listing: obj.listing ? {
          ...obj.listing,
          price: parseFloat(obj.listing.price),
          image_urls: obj.listing.images || [],
        } : null,
      };
    });

    res.json({ offers: formatted });
  } catch (error) {
    console.error('Get my offers error:', error);
    res.status(500).json({ error: 'Failed to fetch offers' });
  }
});

// PATCH /listings/offers/:offerId — seller accepts or rejects an offer
router.patch('/offers/:offerId', authenticate, [
  body('status').isIn(['accepted', 'rejected']),
  body('delivery_address').optional().trim(),
  body('delivery_phone').optional().trim(),
], async (req, res) => {
  try {
    const offer = await Offer.findByPk(req.params.offerId, {
      include: [{ model: Listing, as: 'listing' }],
    });
    if (!offer) return res.status(404).json({ error: 'Offer not found' });
    if (offer.listing.user_id !== req.userId) {
      return res.status(403).json({ error: 'Only the seller can respond to offers' });
    }

    await offer.update({ status: req.body.status });

    // If accepted, create an Order and mark listing as reserved
    if (req.body.status === 'accepted') {
      await offer.listing.update({ status: 'reserved' });

      // Reject all other pending offers
      await Offer.update(
        { status: 'rejected' },
        { where: { listing_id: offer.listing_id, status: 'pending', id: { [require('sequelize').Op.ne]: offer.id } } }
      );

      // Create an Order (COD)
      const { Order } = require('../models');
      const order = await Order.create({
        listing_id: offer.listing_id,
        offer_id: offer.id,
        buyer_id: offer.buyer_id,
        seller_id: req.userId,
        amount: offer.amount,
        payment_method: 'cod',
        status: 'pending',
        delivery_address: req.body.delivery_address || offer.message || 'Address pending',
        delivery_phone: req.body.delivery_phone || '',
      });

      res.json({ offer, order });
      return;
    }

    res.json({ offer });
  } catch (error) {
    console.error('Update offer error:', error);
    res.status(500).json({ error: 'Failed to update offer' });
  }
});

module.exports = router;
