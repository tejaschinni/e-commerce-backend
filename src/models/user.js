const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');


const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
    set(value) {
      this.setDataValue('email', value.trim().toLowerCase());
    },
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true,
    unique: true,
  },
  passwordHash: {
    type: DataTypes.STRING(255),
    allowNull: false,
    field: 'password_hash',
  },
  firstName: {
    type: DataTypes.STRING(100),
    allowNull: false,
    field: 'first_name',
  },
  lastName: {
    type: DataTypes.STRING(100),
    allowNull: false,
    field: 'last_name',
  },
  role: {
    type: DataTypes.ENUM('customer', 'seller', 'admin', 'support'),
    defaultValue: 'customer',
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'suspended', 'pending_verification'),
    defaultValue: 'pending_verification',
    allowNull: false,
  },
  isEmailVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_email_verified',
  },
  isPhoneVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_phone_verified',
  },
  preferences: {
    type: DataTypes.JSONB,
    defaultValue: {
      currency: 'USD',
      language: 'en',
      marketing_emails: false,
      push_notifications: true,
    },
  },
  lastLoginAt: {
    type: DataTypes.DATE,
    field: 'last_login_at',
  },
  failedLoginAttempts: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    field: 'failed_login_attempts',
  },
  lockoutUntil: {
    type: DataTypes.DATE,
    field: 'lockout_until',
  },
}, {
  tableName: 'mst_user',
  timestamps: true,
  paranoid: true, // Enables soft deletes via deletedAt
  underscored: true, // Automatically converts camelCase to snake_case for timestamps
  indexes: [
    { unique: true, fields: ['email'] },
    { unique: true, fields: ['phone'] },
    { fields: ['role', 'status'] },
    { using: 'gin', fields: ['preferences'] },
  ],
});

// Automatic response serialization (strips sensitive fields)
User.prototype.toJSON = function () {
  const values = { ...this.get() };
  delete values.passwordHash;
  delete values.failedLoginAttempts;
  delete values.lockoutUntil;
  return values;
};

module.exports = User;