-- Create review_schedule table
-- Manages spaced repetition scheduling for each child/chunk

CREATE TABLE IF NOT EXISTS review_schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    chunk_id UUID NOT NULL REFERENCES ayah_chunks(id) ON DELETE CASCADE,
    next_review_at TIMESTAMPTZ NOT NULL,
    interval_days INTEGER NOT NULL DEFAULT 1,
    ease_factor REAL NOT NULL DEFAULT 2.5 CHECK (ease_factor >= 1.3),
    repetitions INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(child_id, chunk_id)
);

-- Enable Row Level Security
ALTER TABLE review_schedule ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Parents can view their children schedules"
    ON review_schedule FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM children
            WHERE children.id = review_schedule.child_id
            AND children.parent_id = auth.uid()
        )
    );

CREATE POLICY "Parents can insert schedules for their children"
    ON review_schedule FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM children
            WHERE children.id = review_schedule.child_id
            AND children.parent_id = auth.uid()
        )
    );

CREATE POLICY "Parents can update their children schedules"
    ON review_schedule FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM children
            WHERE children.id = review_schedule.child_id
            AND children.parent_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_review_schedule_child_id ON review_schedule(child_id);
CREATE INDEX idx_review_schedule_next_review ON review_schedule(next_review_at);
CREATE INDEX idx_review_schedule_child_next ON review_schedule(child_id, next_review_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for updated_at
CREATE TRIGGER update_review_schedule_updated_at
    BEFORE UPDATE ON review_schedule
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
