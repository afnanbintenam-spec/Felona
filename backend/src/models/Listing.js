const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Listing = sequelize.define('Listing', {
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
  title: {
    type: DataTypes.STRING(200),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  category: {
    type: DataTypes.ENUM('plastic', 'metal', 'paper', 'glass', 'electronics', 'textile', 'furniture', 'other'),
    allowNull: false,
  },
  condition: {
    type: DataTypes.ENUM('new', 'like_new', 'good', 'fair', 'poor'),
    defaultValue: 'good',
  },
  images: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
  },
  status: {
    type: DataTypes.ENUM('active', 'sold', 'reserved', 'expired'),
    defaultValue: 'active',
  },
  views: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  eco_points_reward: {
    type: DataTypes.INTEGER,
    defaultValue: 10,
  },
}, {
  tableName: 'listings',
  timestamps: true,
  underscored: true,
  paranoid: true, // soft delete
});

module.exports = Listing;
