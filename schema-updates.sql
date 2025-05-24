-- Add name field to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Add review scheduling fields to projects table
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_frequency TEXT DEFAULT 'quarterly' CHECK (review_frequency IN ('monthly', 'quarterly', 'yearly', 'custom'));

-- Add period description and status
ALTER TABLE projects ADD COLUMN IF NOT EXISTS period_description TEXT;

-- Update status field to use 'active' by default, only 'complete' after end-of-period review
ALTER TABLE projects ALTER COLUMN status SET DEFAULT 'active';
UPDATE projects SET status = 'active' WHERE status IS NULL OR status = '';

-- Add constraint to ensure only valid status values
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_status_check;
ALTER TABLE projects ADD CONSTRAINT projects_status_check CHECK (status IN ('active', 'complete', 'paused'));