-- Schema for RoadSOS Module 2: Emergency Contact Management System (Supabase PostgreSQL)

CREATE TABLE IF NOT EXISTS public.emergency_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own emergency contacts
CREATE POLICY "Users can view own emergency contacts" 
ON public.emergency_contacts FOR SELECT 
USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own emergency contacts
CREATE POLICY "Users can insert own emergency contacts" 
ON public.emergency_contacts FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own emergency contacts
CREATE POLICY "Users can update own emergency contacts" 
ON public.emergency_contacts FOR UPDATE 
USING (auth.uid() = user_id);

-- RLS Policy: Users can delete their own emergency contacts
CREATE POLICY "Users can delete own emergency contacts" 
ON public.emergency_contacts FOR DELETE 
USING (auth.uid() = user_id);
