-- Seed data for MVP surahs
-- Al-Duha (93) and Al-Ikhlas (112)

INSERT INTO surahs (id, name_ar, name_en, total_ayahs, revelation_type) VALUES
    (93, 'الضحى', 'Ad-Duha', 11, 'meccan'),
    (112, 'الإخلاص', 'Al-Ikhlas', 4, 'meccan')
ON CONFLICT (id) DO NOTHING;

-- Seed ayah chunks for Al-Ikhlas (4 ayahs, 2 chunks)
INSERT INTO ayah_chunks (surah_id, chunk_index, ayah_start, ayah_end, display_text, visual_key) VALUES
    (112, 1, 1, 2, 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ', 'unity_light'),
    (112, 2, 3, 4, 'لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ', 'eternal_star')
ON CONFLICT (surah_id, chunk_index) DO NOTHING;

-- Seed ayah chunks for Al-Duha (11 ayahs, 4 chunks)
INSERT INTO ayah_chunks (surah_id, chunk_index, ayah_start, ayah_end, display_text, visual_key) VALUES
    (93, 1, 1, 3, 'وَالضُّحَىٰ ۝ وَاللَّيْلِ إِذَا سَجَىٰ ۝ مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ', 'dawn_moon'),
    (93, 2, 4, 5, 'وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ ۝ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ', 'gift_heart'),
    (93, 3, 6, 8, 'أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ ۝ وَوَجَدَكَ ضَالًّا فَهَدَىٰ ۝ وَوَجَدَكَ عَائِلًا فَأَغْنَىٰ', 'shelter_path'),
    (93, 4, 9, 11, 'فَأَمَّا الْيَتِيمَ فَلَا تَقْهَرْ ۝ وَأَمَّا السَّائِلَ فَلَا تَنْهَرْ ۝ وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ', 'kindness_blessing')
ON CONFLICT (surah_id, chunk_index) DO NOTHING;
