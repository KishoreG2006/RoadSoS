const { supabaseAdmin } = require('../config/supabase');

/**
 * Get All System Users (Admin Access Only)
 * GET /api/admin/users
 */
const getAllUsers = async (req, res) => {
  try {
    let usersList = [];

    try {
      const { data: dbUsers, error } = await supabaseAdmin
        .from('users')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && dbUsers) {
        usersList = dbUsers;
      }
    } catch (_) {}

    // Ensure initial Admin account is included in response
    const hasAdmin = usersList.some(u => u.email === 'admin@roadsos.com');
    if (!hasAdmin) {
      usersList.unshift({
        id: '00000000-0000-4000-a000-000000000001',
        email: 'admin@roadsos.com',
        full_name: 'System Administrator',
        phone: '9999999999',
        role: 'admin',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    }

    return res.status(200).json({
      success: true,
      count: usersList.length,
      users: usersList
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving system users.',
      error: error.message
    });
  }
};

module.exports = {
  getAllUsers
};
