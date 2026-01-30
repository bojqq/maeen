-- Create ayah_chunks table
-- Stores chunks of ayahs for learning/practice

CREATE TABLE IF NOT EXISTS ayah_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    surah_id INTEGER NOT NULL REFERENCES surahs(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    ayah_start INTEGER NOT NULL,
    ayah_end INTEGER NOT NULL,
    display_text TEXT NOT NULL,
    visual_key TEXT,
    audio_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(surah_id, chunk_index)
);

-- Enable Row Level Security
ALTER TABLE ayah_chunks ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Anyone can view ayah chunks"
    ON ayah_chunks FOR SELECT
    TO authenticated, anon
    USING (true);

-- Indexes
CREATE INDEX idx_ayah_chunks_surah_id ON ayah_chunks(surah_id);
CREATE INDEX idx_ayah_chunks_surah_chunk ON ayah_chunks(surah_id, chunk_index);
