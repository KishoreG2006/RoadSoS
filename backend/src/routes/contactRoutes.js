const express = require('express');
const router = express.Router();
const {
  addContact,
  getContacts,
  updateContact,
  deleteContact,
  syncContacts
} = require('../controllers/contactController');
const { authenticateToken } = require('../middleware/auth');

// All Emergency Contact Routes are protected by JWT Auth
router.post('/', authenticateToken, addContact);
router.get('/', authenticateToken, getContacts);
router.put('/:id', authenticateToken, updateContact);
router.delete('/:id', authenticateToken, deleteContact);
router.post('/sync', authenticateToken, syncContacts);

module.exports = router;
