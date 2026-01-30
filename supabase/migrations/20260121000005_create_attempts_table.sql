-- Create attempts table
-- Stores practice/game attempts for each child

CREATE TABLE IF NOT EXISTS attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    chunk_id UUID NOT NULL REFERENCES ayah_chunks(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('order_game', 'missing_segment', 'recite')),
    score REAL NOT NULL CHECK (score >= 0 AND score <= 1),
    mistakes JSONB DEFAULT '[]'::jsonb,
    time_spent_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE attempts ENABLE ROW LEVEL SECURITY;

-- Policies (parents can view their children's attempts)
CREATE POLICY "Parents can view their children attempts"
    ON attempts FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM children
            WHERE children.id = attempts.child_id
            AND children.parent_id = auth.uid()
        )
    );

CREATE POLICY "Children can insert their own attempts"
    ON attempts FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM children
            WHERE children.id = attempts.child_id
            AND children.parent_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_attempts_child_id ON attempts(child_id);
CREATE INDEX idx_attempts_chunk_id ON attempts(chunk_id);
CREATE INDEX idx_attempts_created_at ON attempts(created_at DESC);
