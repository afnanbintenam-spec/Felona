const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  listing_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'listings', key: 'id' },
  },
  offer_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'offers', key: 'id' },
  },
  buyer_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  seller_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  collector_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'users', key: 'id' },
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  payment_method: {
    type: DataTypes.ENUM('cod'),
    defaultValue: 'cod',
  },
  status: {
    type: DataTypes.ENUM(
      'pending',       // Seller accepted offer, waiting for collector
      'accepted',      // Collector accepted delivery job
      'picked_up',     // Collector picked up from seller
      'in_transit',    // On the way to buyer
      'delivered',     // Delivered to buyer
      'completed',     // Buyer confirmed, payment done
      'cancelled',     // Cancelled by any party
      'rejected'       // Collector rejected
    ),
    defaultValue: 'pending',
  },
  delivery_address: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  delivery_phone: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },
  pickup_address: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  seller_phone: {
    type: DataTypes.STRING(20),
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  accepted_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  picked_up_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  delivered_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  completed_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  cancelled_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  cancellation_reason: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'orders',
  timestamps: true,
  underscored: true,
});

module.exports = Order;
