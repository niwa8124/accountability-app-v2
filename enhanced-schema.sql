-- Enhanced schema to support signatures and agreement history
-- Run this after the existing schema

-- Add signature fields to the agreements table
ALTER TABLE agreements ADD COLUMN IF NOT EXISTS creator_signed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE agreements ADD COLUMN IF NOT EXISTS partner_signed_at TIMESTAMP WITH TIME ZONE;

-- Add step tracking to projects
ALTER TABLE projects ADD COLUMN IF NOT EXISTS current_step INTEGER DEFAULT 1;

-- Create agreement_history table for tracking completed agreements
CREATE TABLE IF NOT EXISTS agreement_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
  creator_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  partner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  creator_vision TEXT NOT NULL,
  partner_vision TEXT NOT NULL,
  creator_signed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  partner_signed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS for agreement_history
ALTER TABLE agreement_history ENABLE ROW LEVEL SECURITY;

-- RLS policy for agreement_history
CREATE POLICY "Users can view own agreement history" ON agreement_history FOR SELECT 
  USING (auth.uid() = creator_id OR auth.uid() = partner_id);

CREATE POLICY "Users can create agreement history" ON agreement_history FOR INSERT 
  WITH CHECK (auth.uid() = creator_id OR auth.uid() = partner_id);