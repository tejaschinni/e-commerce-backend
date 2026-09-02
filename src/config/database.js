// config/database.js
require('dotenv').config();
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.PGDATABASE,
  process.env.PGUSER,
  process.env.PGPASSWORD,
  {
    host: process.env.PGHOST || 'localhost',
    port: process.env.PGPORT || 5432,
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
    // For cloud-hosted databases requiring SSL (e.g. Supabase, RDS):
    // dialectOptions: {
    //   ssl: { require: true, rejectUnauthorized: false }
    // }
  }
);

module.exports = sequelize;