-- Create surahs table
-- Stores Quran surah metadata

CREATE TABLE IF NOT EXISTS surahs (
    id INTEGER PRIMARY KEY,
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    total_ayahs INTEGER NOT NULL,
    revelation_type TEXT CHECK (revelation_type IN ('meccan', 'medinan')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE surahs ENABLE ROW LEVEL SECURITY;

-- Public read access (no auth required for surah metadata)
CREATE POLICY "Anyone can view surahs"
    ON surahs FOR SELECT
    TO authenticated, anon
    USING (true);
