const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const db = require('./config/db');
const userRoutes = require('./routes/user_routes');
const errorHandler = require('./middlewares/errorHandler');
const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.use('/api/v1/users', userRoutes);
app.use(errorHandler);

// Health check route
app.get('/health', async (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});


module.exports = app;