// src/config/initDb.js
const db = require('./db');

const initDb = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS demotable (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      title VARCHAR(255) NOT NULL,
      description TEXT,
      price NUMERIC(10, 2) NOT NULL,
      stock INTEGER DEFAULT 0 NOT NULL,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
    );

    CREATE TABLE IF NOT EXISTS demoorder (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id VARCHAR(255) NOT NULL,
      total_amount NUMERIC(10, 2) NOT NULL,
      status VARCHAR(50) DEFAULT 'PENDING' NOT NULL,
      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
  `;
  await db.query(queryText);
  console.log('[db] Schema initialized successfully');
};

module.exports = initDb;