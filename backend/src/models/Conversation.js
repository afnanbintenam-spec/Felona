const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Conversation = sequelize.define('Conversation', {
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
  last_message: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  last_message_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  buyer_unread_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  seller_unread_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  tableName: 'conversations',
  timestamps: true,
  underscored: true,
});

module.exports = Conversation;
