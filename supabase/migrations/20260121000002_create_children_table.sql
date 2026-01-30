-- Create children table
-- Links children to their parent profiles

CREATE TABLE IF NOT EXISTS children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 3 AND age <= 18),
    level TEXT NOT NULL DEFAULT 'beginner' CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE children ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Parents can view their children"
    ON children FOR SELECT
    USING (auth.uid() = parent_id);

CREATE POLICY "Parents can insert children"
    ON children FOR INSERT
    WITH CHECK (auth.uid() = parent_id);

CREATE POLICY "Parents can update their children"
    ON children FOR UPDATE
    USING (auth.uid() = parent_id);

CREATE POLICY "Parents can delete their children"
    ON children FOR DELETE
    USING (auth.uid() = parent_id);

-- Index for faster lookups
CREATE INDEX idx_children_parent_id ON children(parent_id);
