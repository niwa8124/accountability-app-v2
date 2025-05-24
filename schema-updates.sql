-- Add name field to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Add review scheduling fields to projects table
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS review_frequency TEXT DEFAULT 'quarterly' CHECK (review_frequency IN ('monthly', 'quarterly', 'yearly', 'custom'));

-- Update terminology: projects -> accountability_periods (we'll keep the table name for now but update UI)
-- Add period description
ALTER TABLE projects ADD COLUMN IF NOT EXISTS period_description TEXT;