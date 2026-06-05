const express = require('express');
const { body, validationResult } = require('express-validator');
const { Order, Listing, User, Offer, EcoActivity } = require('../models');
const { authenticate } = require('../middleware/auth');
const { Op } = require('sequelize');

const router = express.Router();

// ─── Helper: format order for Flutter ────────────────────────
function formatOrder(order) {
  const o = order.toJSON ? order.toJSON() : order;
  return {
    id: o.id,
    listing_id: o.listing_id,
    offer_id: o.offer_id,
    buyer_id: o.buyer_id,
    seller_id: o.seller_id,
    collector_id: o.collector_id,
    amount: parseFloat(o.amount),
    payment_method: o.payment_method,
    status: o.status,
    delivery_address: o.delivery_address,
    delivery_phone: o.delivery_phone,
    pickup_address: o.pickup_address,
    seller_phone: o.seller_phone,
    notes: o.notes,
    accepted_at: o.accepted_at,
    picked_up_at: o.picked_up_at,
    delivered_at: o.delivered_at,
    completed_at: o.completed_at,
    cancelled_at: o.cancelled_at,
    cancellation_reason: o.cancellation_reason,
    created_at: o.created_at || o.createdAt,
    updated_at: o.updated_at || o.updatedAt,
    // Include related data if loaded
    listing: o.listing ? {
      id: o.listing.id,
      title: o.listing.title,
      price: parseFloat(o.listing.price || 0),
      image_urls: o.listing.images || [],
      category: o.listing.category,
    } : null,
    buyer: o.buyer ? {
      id: o.buyer.id,
      name: o.buyer.full_name,
      avatar: o.buyer.profile_picture_url,
    } : null,
    seller: o.seller ? {
      id: o.seller.id,
      name: o.seller.full_name,
      avatar: o.seller.profile_picture_url,
    } : null,
    collector: o.collector ? {
      id: o.collector.id,
      name: o.collector.full_name,
      avatar: o.collector.profile_picture_url,
      phone: o.collector.phone_number,
    } : null,
  };
}

const includeAll = [
  { model: Listing, as: 'listing', attributes: ['id', 'title', 'price', 'images', 'category'] },
  { model: User, as: 'buyer', attributes: ['id', 'full_name', 'profile_picture_url'] },
  { model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] },
  { model: User, as: 'collector', attributes: ['id', 'full_name', 'profile_picture_url', 'phone_number'] },
];

// ─── GET /orders — user's orders (buyer or seller) ───────────
router.get('/', authenticate, async (req, res) => {
  try {
    const { role } = req.query; // 'buyer', 'seller', 'collector'
    let where = {};

    if (role === 'seller') {
      where.seller_id = req.userId;
    } else if (role === 'collector') {
      where.collector_id = req.userId;
    } else {
      // Default: buyer's orders
      where.buyer_id = req.userId;
    }

    const orders = await Order.findAll({
      where,
      include: includeAll,
      order: [['created_at', 'DESC']],
    });

    res.json({ orders: orders.map(formatOrder) });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// ─── GET /orders/available — for collectors to see pending deliveries ─
router.get('/available', authenticate, async (req, res) => {
  try {
    const orders = await Order.findAll({
      where: { status: 'pending', collector_id: null },
      include: includeAll,
      order: [['created_at', 'ASC']],
    });

    res.json({ orders: orders.map(formatOrder) });
  } catch (error) {
    console.error('Get available orders error:', error);
    res.status(500).json({ error: 'Failed to fetch available orders' });
  }
});

// ─── GET /orders/:id — single order details ──────────────────
router.get('/:id', authenticate, async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id, { include: includeAll });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // Only participants can view
    const allowed = [order.buyer_id, order.seller_id, order.collector_id];
    if (!allowed.includes(req.userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ order: formatOrder(order) });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

// ─── POST /orders/:id/accept — collector accepts delivery ────
router.post('/:id/accept', authenticate, async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });
    if (order.status !== 'pending') {
      return res.status(400).json({ error: 'Order is not available for pickup' });
    }

    await order.update({
      collector_id: req.userId,
      status: 'accepted',
      accepted_at: new Date(),
    });

    const full = await Order.findByPk(order.id, { include: includeAll });
    res.json({ order: formatOrder(full) });
  } catch (error) {
    console.error('Accept order error:', error);
    res.status(500).json({ error: 'Failed to accept order' });
  }
});

// ─── PATCH /orders/:id/status — update order status ──────────
router.patch('/:id/status', authenticate, [
  body('status').isIn(['picked_up', 'in_transit', 'delivered', 'completed', 'cancelled']),
  body('cancellation_reason').optional().trim(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: 'Invalid status', details: errors.array() });
    }

    const order = await Order.findByPk(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // Permission check
    const allowed = [order.buyer_id, order.seller_id, order.collector_id];
    if (!allowed.includes(req.userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const newStatus = req.body.status;
    const updates = { status: newStatus };

    // Set timestamps based on status
    switch (newStatus) {
      case 'picked_up':
        updates.picked_up_at = new Date();
        break;
      case 'delivered':
        updates.delivered_at = new Date();
        break;
      case 'completed':
        updates.completed_at = new Date();
        // Award eco points on completion
        const buyer = await User.findByPk(order.buyer_id);
        const seller = await User.findByPk(order.seller_id);
        if (buyer) {
          await buyer.increment('eco_points', { by: 10 });
          await EcoActivity.create({
            user_id: order.buyer_id,
            type: 'item_bought',
            points: 10,
            description: 'Purchased a secondhand item — choosing reuse! ♻️',
          });
        }
        if (seller) {
          await seller.increment('eco_points', { by: 20 });
          await EcoActivity.create({
            user_id: order.seller_id,
            type: 'item_sold',
            points: 20,
            description: 'Sold an item — giving it a second life! 🎉',
          });
        }
        // Mark listing as sold
        await Listing.update({ status: 'sold' }, { where: { id: order.listing_id } });
        break;
      case 'cancelled':
        updates.cancelled_at = new Date();
        updates.cancellation_reason = req.body.cancellation_reason || null;
        // Revert listing to active if cancelled
        await Listing.update({ status: 'active' }, { where: { id: order.listing_id } });
        break;
    }

    await order.update(updates);

    const full = await Order.findByPk(order.id, { include: includeAll });
    res.json({ order: formatOrder(full) });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

module.exports = router;
