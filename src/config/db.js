// src/config/db.js
const { Pool } = require('pg');
const dotenv = require('dotenv');

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                       // Maximum number of clients in the pool
  idleTimeoutMillis: 30000,      // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error after 2s if a connection cannot be acquired
  maxUses: 7500,                 // Close and replace client after 7500 queries to prevent memory leaks
});

// Capture unexpected errors on idle pool clients
pool.on('error', (err) => {
  console.error('[pg-pool] Unexpected error on idle client:', err.message);
});

module.exports = {
  // Direct parameterized query helper (auto-acquires and auto-releases client)
  query: (text, params) => pool.query(text, params),

  // Dedicated transaction helper with automatic commit/rollback and client release
  transaction: async (callback) => {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  },

  // Expose pool for graceful shutdown or manual client checkout
  pool,
};