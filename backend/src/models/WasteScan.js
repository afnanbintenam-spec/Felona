const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const WasteScan = sequelize.define('WasteScan', {
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
  image_url: {
    type: DataTypes.STRING(500),
    allowNull: true,
  },
  // AI analysis results
  item_name: {
    type: DataTypes.STRING(200),
    allowNull: false,
  },
  material: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  category: {
    type: DataTypes.ENUM('plastic', 'metal', 'paper', 'glass', 'electronics', 'organic', 'textile', 'mixed', 'unknown'),
    allowNull: false,
  },
  is_recyclable: {
    type: DataTypes.ENUM('yes', 'no', 'partially'),
    defaultValue: 'no',
  },
  confidence: {
    type: DataTypes.DECIMAL(3, 2), // 0.00 to 1.00
    defaultValue: 0,
  },
  // Eco impact
  estimated_weight_kg: {
    type: DataTypes.DECIMAL(6, 2),
    defaultValue: 0,
  },
  co2_saved_kg: {
    type: DataTypes.DECIMAL(6, 2),
    defaultValue: 0,
  },
  landfill_saved_kg: {
    type: DataTypes.DECIMAL(6, 2),
    defaultValue: 0,
  },
  // Recommendations
  recommended_action: {
    type: DataTypes.ENUM('recycle', 'reuse', 'sell', 'pickup', 'dispose'),
    allowNull: false,
  },
  disposal_method: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  estimated_value_min: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  estimated_value_max: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  danger_level: {
    type: DataTypes.ENUM('none', 'low', 'medium', 'high'),
    defaultValue: 'none',
  },
  eco_tip: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  points_earned: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  // Raw AI response for debugging
  raw_response: {
    type: DataTypes.JSONB,
    defaultValue: {},
  },
}, {
  tableName: 'waste_scans',
  timestamps: true,
  underscored: true,
});

module.exports = WasteScan;
