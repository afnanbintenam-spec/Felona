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
    type: DataTypes.ENUM('requested', 'accepted', 'on_the_way', 'collected', 'recycled', 'cancelled'),
    defaultValue: 'requested',
  },
  scheduled_date: {
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
