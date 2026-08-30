const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://xyzcompany.supabase.co';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'dummy_key';
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY || 'dummy_key';

// Standard client for auth & user operations
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Admin client for bypassing RLS during profile setup if needed
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

module.exports = {
  supabase,
  supabaseAdmin
};
