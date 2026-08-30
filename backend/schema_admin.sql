-- SQL Migration for Admin Role & System User Management

-- Add role column to public.users table if it does not exist
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user';

-- Seed initial Admin User Profile
INSERT INTO public.users (id, email, full_name, phone, role, created_at, updated_at)
VALUES (
    '00000000-0000-4000-a000-000000000001',
    'admin@roadsos.com',
    'System Administrator',
    '9999999999',
    'admin',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE 
SET role = 'admin', full_name = 'System Administrator';
