-- Ensure full_name column exists
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Update the trigger function to handle the full_name from metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id, 
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.user_metadata ->> 'full_name')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing users who might be missing names
UPDATE profiles 
SET full_name = auth.users.raw_user_meta_data ->> 'full_name'
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND profiles.full_name IS NULL 
AND auth.users.raw_user_meta_data ->> 'full_name' IS NOT NULL;