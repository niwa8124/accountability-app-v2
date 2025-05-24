-- Safe schema updates - only add what doesn't exist yet

-- Add name field to profiles table (if not exists)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Add review scheduling fields to projects table (if not exists)
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_frequency TEXT DEFAULT 'quarterly';

-- Add period description (if not exists)
ALTER TABLE projects ADD COLUMN IF NOT EXISTS period_description TEXT;

-- Update existing projects to have active status (only if status is null/empty)
UPDATE projects SET status = 'active' WHERE status IS NULL OR status = '';