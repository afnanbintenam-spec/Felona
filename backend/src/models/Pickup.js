const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pickup = sequelize.define('Pickup', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  collector_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'users', key: 'id' },
  },
  waste_category: {
    type: DataTypes.ENUM('plastic', 'metal', 'paper', 'glass', 'electronics', 'organic', 'mixed', 'other'),
    allowNull: false,
  },
  estimated_weight: {
    type: DataTypes.DECIMAL(6, 2),
    allowNull: false,
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('pending', 'assigned', 'accepted', 'on_the_way', 'arrived', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },

  // ─── Scheduling ─────────────────────────────────────────────
  scheduled_date: {
    type: DataTypes.DATEONLY,
    allowNull: true,
  },
  time_slot: {
    type: DataTypes.STRING(20),
    allowNull: true,
    comment: 'e.g. 08:00-10:00, 10:00-12:00',
  },
  is_recurring: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  recurrence_frequency: {
    type: DataTypes.ENUM('weekly', 'biweekly'),
    allowNull: true,
  },
  recurrence_day: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '1=Monday, 7=Sunday',
  },
  recurring_schedule_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: 'Groups recurring pickups together',
  },

  // ─── QR Verification ────────────────────────────────────────
  qr_token: {
    type: DataTypes.STRING(64),
    allowNull: true,
    unique: true,
    comment: '128-bit token for QR verification',
  },

  // ─── Tracking ───────────────────────────────────────────────
  collector_latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
  },
  collector_longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
  },
  eta_minutes: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },

  // ─── Rating ─────────────────────────────────────────────────
  rating: {
    type: DataTypes.DECIMAL(2, 1),
    allowNull: true,
    validate: { min: 1, max: 5 },
  },
  feedback: {
    type: DataTypes.TEXT,
    allowNull: true,
  },

  // ─── Completion ─────────────────────────────────────────────
  accepted_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  completed_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  eco_points_earned: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  weight_saved: {
    type: DataTypes.DECIMAL(6, 2),
    defaultValue: 0,
  },
}, {
  tableName: 'pickups',
  timestamps: true,
  underscored: true,
  paranoid: true,
});

module.exports = Pickup;
