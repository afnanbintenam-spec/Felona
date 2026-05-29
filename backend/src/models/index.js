const sequelize = require('../config/database');
const User = require('./User');
const Listing = require('./Listing');
const Pickup = require('./Pickup');
const Offer = require('./Offer');
const EcoActivity = require('./EcoActivity');
const Otp = require('./Otp');
const WasteScan = require('./WasteScan');
const Notification = require('./Notification');

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

module.exports = {
  sequelize,
  User,
  Listing,
  Pickup,
  Offer,
  EcoActivity,
  Otp,
  WasteScan,
  Notification,
};
