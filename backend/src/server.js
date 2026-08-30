const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const contactRoutes = require('./routes/contactRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Security and CORS middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'online',
    service: 'RoadSOS Application API',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/emergency-contacts', contactRoutes);
app.use('/api/admin', adminRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.originalUrl} not found on server`
  });
});

// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Global Error Handler:', err.stack);
  res.status(500).json({
    success: false,
    message: 'An unexpected server error occurred',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(` RoadSOS Backend Server running on port ${PORT}`);
  console.log(` API Auth: http://localhost:${PORT}/api/auth`);
  console.log(` API Contacts: http://localhost:${PORT}/api/emergency-contacts`);
  console.log(` API Admin: http://localhost:${PORT}/api/admin/users`);
  console.log(`=================================================`);
});
