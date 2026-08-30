const express = require('express');
const router = express.Router();
const { getAllUsers } = require('../controllers/adminController');
const { authenticateAdmin } = require('../middleware/auth');

// Protected Admin Route
router.get('/users', authenticateAdmin, getAllUsers);

module.exports = router;
