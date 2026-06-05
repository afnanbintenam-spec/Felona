const sequelize = require('../config/database');
const User = require('./User');
const Listing = require('./Listing');
const Pickup = require('./Pickup');
const Offer = require('./Offer');
const Order = require('./Order');
const EcoActivity = require('./EcoActivity');
const Otp = require('./Otp');
const WasteScan = require('./WasteScan');
const Notification = require('./Notification');
const Conversation = require('./Conversation');
const Message = require('./Message');

// ─── Associations ─────────────────────────────────────────────

// User has many Listings
User.hasMany(Listing, { foreignKey: 'user_id', as: 'listings' });
Listing.belongsTo(User, { foreignKey: 'user_id', as: 'seller' });

// User has many Pickups (as requester)
User.hasMany(Pickup, { foreignKey: 'user_id', as: 'pickups' });
Pickup.belongsTo(User, { foreignKey: 'user_id', as: 'requester' });

// User has many Pickups (as collector)
User.hasMany(Pickup, { foreignKey: 'collector_id', as: 'collections' });
Pickup.belongsTo(User, { foreignKey: 'collector_id', as: 'collector' });

// Listing has many Offers
Listing.hasMany(Offer, { foreignKey: 'listing_id', as: 'offers' });
Offer.belongsTo(Listing, { foreignKey: 'listing_id', as: 'listing' });

// User has many Offers (as buyer)
User.hasMany(Offer, { foreignKey: 'buyer_id', as: 'offers' });
Offer.belongsTo(User, { foreignKey: 'buyer_id', as: 'buyer' });

// User has many EcoActivities
User.hasMany(EcoActivity, { foreignKey: 'user_id', as: 'activities' });
EcoActivity.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// User has many WasteScans
User.hasMany(WasteScan, { foreignKey: 'user_id', as: 'scans' });
WasteScan.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// User has many Notifications
User.hasMany(Notification, { foreignKey: 'user_id', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// ─── Conversation Associations ────────────────────────────────

// Conversation belongs to a Listing
Listing.hasMany(Conversation, { foreignKey: 'listing_id', as: 'conversations' });
Conversation.belongsTo(Listing, { foreignKey: 'listing_id', as: 'listing' });

// Conversation buyer/seller
User.hasMany(Conversation, { foreignKey: 'buyer_id', as: 'bought_conversations' });
Conversation.belongsTo(User, { foreignKey: 'buyer_id', as: 'buyer' });

User.hasMany(Conversation, { foreignKey: 'seller_id', as: 'sold_conversations' });
Conversation.belongsTo(User, { foreignKey: 'seller_id', as: 'seller' });

// Message belongs to Conversation
Conversation.hasMany(Message, { foreignKey: 'conversation_id', as: 'messages' });
Message.belongsTo(Conversation, { foreignKey: 'conversation_id', as: 'conversation' });

// Message has a sender
User.hasMany(Message, { foreignKey: 'sender_id', as: 'sent_messages' });
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });

// ─── Order Associations ───────────────────────────────────────

// Order belongs to Listing
Listing.hasMany(Order, { foreignKey: 'listing_id', as: 'orders' });
Order.belongsTo(Listing, { foreignKey: 'listing_id', as: 'listing' });

// Order belongs to Offer
Offer.hasOne(Order, { foreignKey: 'offer_id', as: 'order' });
Order.belongsTo(Offer, { foreignKey: 'offer_id', as: 'offer' });

// Order belongs to Buyer
User.hasMany(Order, { foreignKey: 'buyer_id', as: 'purchases' });
Order.belongsTo(User, { foreignKey: 'buyer_id', as: 'buyer' });

// Order belongs to Seller
User.hasMany(Order, { foreignKey: 'seller_id', as: 'sales' });
Order.belongsTo(User, { foreignKey: 'seller_id', as: 'seller' });

// Order optionally belongs to Collector (delivery rider)
Order.belongsTo(User, { foreignKey: 'collector_id', as: 'collector' });

module.exports = {
  sequelize,
  User,
  Listing,
  Pickup,
  Offer,
  Order,
  EcoActivity,
  Otp,
  WasteScan,
  Notification,
  Conversation,
  Message,
};
