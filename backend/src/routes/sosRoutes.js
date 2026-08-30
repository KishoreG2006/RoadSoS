const express = require('express');
const router = express.Router();
const { receiveDtnBundle, getSosReports } = require('../controllers/sosController');

// Gateway DTN Endpoint (Accepts direct cloud uploads from mobile DTN engine & mesh peers)
router.post('/dtn-gateway', receiveDtnBundle);

// Admin / System SOS reports endpoint
router.get('/reports', getSosReports);

module.exports = router;
