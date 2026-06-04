const express = require('express');
const { Op } = require('sequelize');
const { body, validationResult } = require('express-validator');
const { Conversation, Message, User, Listing } = require('../models');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// ─── Helper: format conversation for Flutter ─────────────────
function formatConversation(conv, currentUserId) {
  const c = conv.toJSON ? conv.toJSON() : conv;
  const listing = c.listing || {};
  const buyer = c.buyer || {};
  const seller = c.seller || {};

  const unreadCount = c.buyer_id === currentUserId
    ? (c.buyer_unread_count || 0)
    : (c.seller_unread_count || 0);

  return {
    id: c.id,
    listing_id: c.listing_id,
    listing_title: listing.title || '',
    listing_image: (listing.images && listing.images.length > 0) ? listing.images[0] : null,
    listing_price: parseFloat(listing.price || 0),
    buyer_id: c.buyer_id,
    buyer_name: buyer.full_name || 'Buyer',
    buyer_avatar: buyer.profile_picture_url || null,
    seller_id: c.seller_id,
    seller_name: seller.full_name || 'Seller',
    seller_avatar: seller.profile_picture_url || null,
    last_message: c.last_message || null,
    last_message_at: c.last_message_at || null,
    unread_count: unreadCount,
    created_at: c.created_at || c.createdAt,
  };
}

// ─── Helper: format message for Flutter ──────────────────────
function formatMessage(msg) {
  const m = msg.toJSON ? msg.toJSON() : msg;
  const sender = m.sender || {};
  return {
    id: m.id,
    conversation_id: m.conversation_id,
    sender_id: m.sender_id,
    sender_name: sender.full_name || 'User',
    content: m.content,
    status: m.status,
    created_at: m.created_at || m.createdAt,
  };
}

// ─── GET /conversations ───────────────────────────────────────
// Returns all conversations for the authenticated user
router.get('/', authenticate, async (req, res) => {
  try {
    const conversations = await Conversation.findAll({
      where: {
        [Op.or]: [
          { buyer_id: req.userId },
          { seller_id: req.userId },
        ],
      },
      include: [
        {
          model: Listing,
          as: 'listing',
          attributes: ['id', 'title', 'price', 'images'],
        },
        {
          model: User,
          as: 'buyer',
          attributes: ['id', 'full_name', 'profile_picture_url'],
        },
        {
          model: User,
          as: 'seller',
          attributes: ['id', 'full_name', 'profile_picture_url'],
        },
      ],
      order: [['last_message_at', 'DESC NULLS LAST']],
    });

    res.json({
      conversations: conversations.map(c => formatConversation(c, req.userId)),
    });
  } catch (err) {
    console.error('GET /conversations error:', err);
    res.status(500).json({ error: 'Failed to fetch conversations' });
  }
});

// ─── POST /conversations ──────────────────────────────────────
// Get or create a conversation for a listing between buyer & seller
router.post(
  '/',
  authenticate,
  [
    body('listing_id').notEmpty().withMessage('listing_id is required'),
    body('seller_id').notEmpty().withMessage('seller_id is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { listing_id, seller_id } = req.body;
    const buyer_id = req.userId;

    // Buyer cannot start a conversation with themselves
    if (buyer_id === seller_id) {
      return res.status(400).json({ error: 'You cannot start a conversation with yourself' });
    }

    try {
      // Check listing exists
      const listing = await Listing.findByPk(listing_id);
      if (!listing) {
        return res.status(404).json({ error: 'Listing not found' });
      }

      // Find existing or create new
      const [conversation, created] = await Conversation.findOrCreate({
        where: { listing_id, buyer_id, seller_id },
        defaults: { listing_id, buyer_id, seller_id },
      });

      // Re-fetch with associations
      const full = await Conversation.findByPk(conversation.id, {
        include: [
          { model: Listing, as: 'listing', attributes: ['id', 'title', 'price', 'images'] },
          { model: User, as: 'buyer', attributes: ['id', 'full_name', 'profile_picture_url'] },
          { model: User, as: 'seller', attributes: ['id', 'full_name', 'profile_picture_url'] },
        ],
      });

      res.status(created ? 201 : 200).json({
        conversation: formatConversation(full, buyer_id),
      });
    } catch (err) {
      console.error('POST /conversations error:', err);
      res.status(500).json({ error: 'Failed to get or create conversation' });
    }
  }
);

// ─── GET /conversations/:id/messages ─────────────────────────
router.get('/:id/messages', authenticate, async (req, res) => {
  try {
    const conversation = await Conversation.findByPk(req.params.id);
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    // Only participants can read messages
    if (conversation.buyer_id !== req.userId && conversation.seller_id !== req.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const messages = await Message.findAll({
      where: { conversation_id: req.params.id },
      include: [
        { model: User, as: 'sender', attributes: ['id', 'full_name', 'profile_picture_url'] },
      ],
      order: [['created_at', 'ASC']],
    });

    res.json({ messages: messages.map(formatMessage) });
  } catch (err) {
    console.error('GET /conversations/:id/messages error:', err);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// ─── POST /conversations/:id/messages ────────────────────────
router.post(
  '/:id/messages',
  authenticate,
  [body('content').trim().notEmpty().withMessage('content is required')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const conversation = await Conversation.findByPk(req.params.id);
      if (!conversation) {
        return res.status(404).json({ error: 'Conversation not found' });
      }

      // Only participants can send messages
      if (conversation.buyer_id !== req.userId && conversation.seller_id !== req.userId) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const message = await Message.create({
        conversation_id: req.params.id,
        sender_id: req.userId,
        content: req.body.content,
        status: 'sent',
      });

      // Update last_message on conversation + increment unread for the other party
      const isBuyer = req.userId === conversation.buyer_id;
      await conversation.update({
        last_message: req.body.content,
        last_message_at: new Date(),
        seller_unread_count: isBuyer
          ? conversation.seller_unread_count + 1
          : conversation.seller_unread_count,
        buyer_unread_count: !isBuyer
          ? conversation.buyer_unread_count + 1
          : conversation.buyer_unread_count,
      });

      // Re-fetch with sender info
      const full = await Message.findByPk(message.id, {
        include: [{ model: User, as: 'sender', attributes: ['id', 'full_name'] }],
      });

      // Broadcast via WebSocket if available
      try {
        const wss = req.app.get('wss');
        const clients = req.app.get('wsClients');
        const otherId = isBuyer ? conversation.seller_id : conversation.buyer_id;
        if (clients && clients.has(otherId)) {
          const ws = clients.get(otherId);
          if (ws.readyState === 1) {
            ws.send(JSON.stringify({
              type: 'new_message',
              conversation_id: req.params.id,
              message: formatMessage(full),
            }));
          }
        }
      } catch (_) { /* WS broadcast is best-effort */ }

      res.status(201).json({ message: formatMessage(full) });
    } catch (err) {
      console.error('POST /conversations/:id/messages error:', err);
      res.status(500).json({ error: 'Failed to send message' });
    }
  }
);

// ─── PATCH /conversations/:id/read ───────────────────────────
router.patch('/:id/read', authenticate, async (req, res) => {
  try {
    const conversation = await Conversation.findByPk(req.params.id);
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }

    if (conversation.buyer_id !== req.userId && conversation.seller_id !== req.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const isBuyer = req.userId === conversation.buyer_id;
    await conversation.update(
      isBuyer
        ? { buyer_unread_count: 0 }
        : { seller_unread_count: 0 }
    );

    // Mark messages as read
    await Message.update(
      { status: 'read' },
      {
        where: {
          conversation_id: req.params.id,
          sender_id: { [Op.ne]: req.userId },
          status: { [Op.ne]: 'read' },
        },
      }
    );

    res.json({ success: true });
  } catch (err) {
    console.error('PATCH /conversations/:id/read error:', err);
    res.status(500).json({ error: 'Failed to mark as read' });
  }
});

module.exports = router;
