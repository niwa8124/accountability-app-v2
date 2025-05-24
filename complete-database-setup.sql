-- Complete database setup for accountability app
-- Run this in Supabase SQL Editor

-- 1. Ensure full_name column exists in profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- 2. Update the trigger function to save names from signup metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id, 
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data ->> 'full_name', 
      NEW.user_metadata ->> 'full_name'
    )
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = COALESCE(
      NEW.raw_user_meta_data ->> 'full_name', 
      NEW.user_metadata ->> 'full_name',
      profiles.full_name
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Add project enhancement fields
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_frequency TEXT DEFAULT 'quarterly';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS period_description TEXT;

-- 4. Update project status management
ALTER TABLE projects ALTER COLUMN status SET DEFAULT 'active';
UPDATE projects SET status = 'active' WHERE status IS NULL OR status = '';

-- 5. Update existing users who might be missing names from metadata
UPDATE profiles 
SET full_name = auth.users.raw_user_meta_data ->> 'full_name'
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND profiles.full_name IS NULL 
AND auth.users.raw_user_meta_data ->> 'full_name' IS NOT NULL;

-- 6. Check the results
SELECT 
  p.email, 
  p.full_name,
  CASE WHEN p.full_name IS NULL THEN 'Missing Name' ELSE 'Has Name' END as name_status
FROM profiles p 
ORDER BY p.created_at DESC 
LIMIT 10;