const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EcoActivity = sequelize.define('EcoActivity', {
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
  type: {
    type: DataTypes.ENUM('pickup_completed', 'item_listed', 'item_sold', 'scan_completed', 'streak_bonus', 'signup_bonus'),
    allowNull: false,
  },
  points: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  description: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {},
  },
}, {
  tableName: 'eco_activities',
  timestamps: true,
  underscored: true,
});

module.exports = EcoActivity;
