const { supabaseAdmin } = require('../config/supabase');
const crypto = require('crypto');

/**
 * Helper to validate 10-digit mobile number
 */
const isValidPhone = (phone) => {
  const phoneRegex = /^[0-9]{10}$/;
  return phoneRegex.test(phone);
};

// In-memory fallback array for local dev mode when Supabase table is pending creation
const inMemoryContacts = [];

/**
 * 1. Add Emergency Contact
 * POST /api/emergency-contacts
 */
const addContact = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : 'default_user_id';
    const { name, phone, relationship } = req.body;

    if (!name || name.trim().length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Contact name is required and must be at least 3 characters long.'
      });
    }

    if (!phone || !isValidPhone(phone.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Phone number must be a valid 10-digit mobile number.'
      });
    }

    if (!relationship) {
      return res.status(400).json({
        success: false,
        message: 'Relationship selection is required.'
      });
    }

    const contactId = crypto.randomUUID();
    const newContact = {
      id: contactId,
      user_id: userId,
      name: name.trim(),
      phone: phone.trim(),
      relationship: relationship.trim(),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabaseAdmin
        .from('emergency_contacts')
        .insert(newContact)
        .select()
        .single();

      if (!error && data) {
        return res.status(201).json({
          success: true,
          message: 'Emergency contact added successfully',
          contact: data
        });
      }
    } catch (_) {}

    // Fallback store
    inMemoryContacts.push(newContact);
    return res.status(201).json({
      success: true,
      message: 'Emergency contact added successfully',
      contact: newContact
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error adding emergency contact.',
      error: error.message
    });
  }
};

/**
 * 2. Get All Emergency Contacts
 * GET /api/emergency-contacts
 */
const getContacts = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : 'default_user_id';

    try {
      const { data, error } = await supabaseAdmin
        .from('emergency_contacts')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (!error && data) {
        return res.status(200).json({
          success: true,
          contacts: data
        });
      }
    } catch (_) {}

    const userMemoryContacts = inMemoryContacts.filter(c => c.user_id === userId);
    return res.status(200).json({
      success: true,
      contacts: userMemoryContacts
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving emergency contacts.',
      error: error.message
    });
  }
};

/**
 * 3. Update Emergency Contact
 * PUT /api/emergency-contacts/:id
 */
const updateContact = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone, relationship } = req.body;

    if (!name || name.trim().length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Contact name must be at least 3 characters long.'
      });
    }

    if (!phone || !isValidPhone(phone.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Phone number must be a valid 10-digit mobile number.'
      });
    }

    const updatedFields = {
      name: name.trim(),
      phone: phone.trim(),
      relationship: relationship.trim(),
      updated_at: new Date().toISOString()
    };

    try {
      const { data, error } = await supabaseAdmin
        .from('emergency_contacts')
        .update(updatedFields)
        .eq('id', id)
        .select()
        .single();

      if (!error && data) {
        return res.status(200).json({
          success: true,
          message: 'Emergency contact updated successfully',
          contact: data
        });
      }
    } catch (_) {}

    const index = inMemoryContacts.findIndex(c => c.id === id);
    if (index !== -1) {
      inMemoryContacts[index] = { ...inMemoryContacts[index], ...updatedFields };
    }

    return res.status(200).json({
      success: true,
      message: 'Emergency contact updated successfully',
      contact: { id, ...updatedFields }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error updating emergency contact.',
      error: error.message
    });
  }
};

/**
 * 4. Delete Emergency Contact
 * DELETE /api/emergency-contacts/:id
 */
const deleteContact = async (req, res) => {
  try {
    const { id } = req.params;

    try {
      await supabaseAdmin
        .from('emergency_contacts')
        .delete()
        .eq('id', id);
    } catch (_) {}

    const index = inMemoryContacts.findIndex(c => c.id === id);
    if (index !== -1) {
      inMemoryContacts.splice(index, 1);
    }

    return res.status(200).json({
      success: true,
      message: 'Emergency contact deleted successfully'
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error deleting emergency contact.',
      error: error.message
    });
  }
};

/**
 * 5. Batch Synchronize Contacts
 * POST /api/emergency-contacts/sync
 */
const syncContacts = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : 'default_user_id';
    const { pending_creations = [], pending_updates = [], pending_deletions = [] } = req.body;

    // Process pending creations
    for (const c of pending_creations) {
      const contactObj = {
        id: c.cloud_id || crypto.randomUUID(),
        user_id: userId,
        name: c.name,
        phone: c.phone,
        relationship: c.relationship,
        created_at: c.created_at || new Date().toISOString(),
        updated_at: c.updated_at || new Date().toISOString()
      };
      try {
        await supabaseAdmin.from('emergency_contacts').upsert(contactObj);
      } catch (_) {
        inMemoryContacts.push(contactObj);
      }
    }

    // Process pending updates
    for (const u of pending_updates) {
      try {
        await supabaseAdmin.from('emergency_contacts').update({
          name: u.name,
          phone: u.phone,
          relationship: u.relationship,
          updated_at: new Date().toISOString()
        }).eq('id', u.cloud_id);
      } catch (_) {}
    }

    // Process pending deletions
    for (const dId of pending_deletions) {
      try {
        await supabaseAdmin.from('emergency_contacts').delete().eq('id', dId);
      } catch (_) {}
    }

    // Fetch latest cloud list
    let latestContacts = [];
    try {
      const { data } = await supabaseAdmin
        .from('emergency_contacts')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });
      if (data) latestContacts = data;
    } catch (_) {
      latestContacts = inMemoryContacts.filter(c => c.user_id === userId);
    }

    return res.status(200).json({
      success: true,
      message: 'Contacts synchronized successfully',
      contacts: latestContacts
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error synchronizing contacts.',
      error: error.message
    });
  }
};

module.exports = {
  addContact,
  getContacts,
  updateContact,
  deleteContact,
  syncContacts
};
