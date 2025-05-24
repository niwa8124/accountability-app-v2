-- Check if full_name column exists in profiles table
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public';

-- If full_name doesn't exist, add it
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Check existing profiles to see if names are missing
SELECT id, email, full_name, created_at FROM profiles LIMIT 5;