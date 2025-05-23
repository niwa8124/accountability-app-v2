-- Update RLS policy to allow project lookup by code for joining
-- This allows authenticated users to find projects by project_code so they can join them

-- Drop the existing restrictive policy
DROP POLICY "Users can view own projects" ON projects;

-- Create new policy that allows:
-- 1. Users to see projects they created or joined (existing functionality)
-- 2. Authenticated users to lookup projects by project_code (for joining)
CREATE POLICY "Users can view projects for joining" ON projects FOR SELECT 
  USING (
    auth.uid() = creator_id 
    OR auth.uid() = partner_id 
    OR (auth.uid() IS NOT NULL AND project_code IS NOT NULL)
  );