-- Update RLS policies to allow project lookup and joining by code
-- This allows authenticated users to find projects by project_code and join them

-- Drop the existing restrictive policies
DROP POLICY "Users can view own projects" ON projects;
DROP POLICY "Users can update own projects" ON projects;

-- Create new SELECT policy that allows:
-- 1. Users to see projects they created or joined (existing functionality)
-- 2. Authenticated users to lookup projects by project_code (for joining)
CREATE POLICY "Users can view projects for joining" ON projects FOR SELECT 
  USING (
    auth.uid() = creator_id 
    OR auth.uid() = partner_id 
    OR (auth.uid() IS NOT NULL AND project_code IS NOT NULL)
  );

-- Create new UPDATE policy that allows:
-- 1. Creators to update their projects
-- 2. Partners to update projects they've joined
-- 3. Authenticated users to join projects (set themselves as partner when partner_id is null)
CREATE POLICY "Users can update projects and join" ON projects FOR UPDATE 
  USING (
    auth.uid() = creator_id 
    OR auth.uid() = partner_id 
    OR (auth.uid() IS NOT NULL AND partner_id IS NULL)
  );