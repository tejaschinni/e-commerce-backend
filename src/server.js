const dotenv = require('dotenv');
const sequelize = require('./config/database');

dotenv.config();

const app = require('./app');

const PORT = process.env.PORT || 4000;
const HOST = '0.0.0.0';

let server;


async function startServer() {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ alter: true });
    
    server = app.listen(PORT, HOST, () => {
      console.log(`[server] API running at http://${HOST}:${PORT}`);
    });
  } catch (err) {
    console.error('[server] Startup failure:', err.message);
    process.exit(1);
  }
}
startServer();
// const server = app.listen(PORT, HOST, () => {
//   console.log(`[server] E-commerce API running on http://${HOST}:${PORT}`);
// });

const handleShutdown = (signal) => {
  console.log(`[server] Received ${signal}. Shutting down cleanly...`);
  server.close(() => {
    console.log('[server] Process terminated.');
    process.exit(0);
  });
};

process.on('SIGINT', () => handleShutdown('SIGINT'));
process.on('SIGTERM', () => handleShutdown('SIGTERM'));