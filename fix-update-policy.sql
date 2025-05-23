-- Fix UPDATE policy to allow project joining
-- Only drop and recreate the UPDATE policy since SELECT policy was already updated

-- Drop the existing UPDATE policy if it exists
DROP POLICY IF EXISTS "Users can update own projects" ON projects;

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