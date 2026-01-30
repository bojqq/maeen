# مَعين Quick Start Guide

## 🚀 Run the App in 5 Minutes

### Step 1: Open Xcode
```bash
cd /Users/ilyasmalghamdi/Documents/maeem
open maeem.xcodeproj
```

### Step 2: Setup Supabase Database
```bash
# Navigate to supabase folder
cd supabase

# Make sure Supabase CLI is installed
# If not: brew install supabase/tap/supabase

# Link to your project (if not already linked)
supabase link --project-ref ghkffyyucdffxsxolzbd

# Apply migrations
supabase db push

# Seed initial data
psql postgresql://postgres:your-password@db.ghkffyyucdffxsxolzbd.supabase.co:5432/postgres -f seed/seed_surahs.sql
```

**Or use Supabase Dashboard:**
1. Go to https://supabase.com/dashboard
2. Open your project: `ghkffyyucdffxsxolzbd`
3. Go to SQL Editor
4. Run each migration file manually
5. Run the seed file

### Step 3: Build & Run
1. In Xcode, select a simulator (iPhone 15 Pro recommended)
2. Press `Cmd + R` or click the Play button
3. Wait for build to complete
4. App will launch with splash screen

### Step 4: Test the App

#### Test as Child:
1. Tap "ابدأ الآن" on welcome screen
2. Select "طفل" (Child)
3. Enter name: "أحمد", age: 8, level: مبتدئ
4. Select "سورة الإخلاص"
5. Tap "تعلّم" to learn chunks
6. Tap "تدرّب" to play games

#### Test as Parent:
1. Restart app (Cmd + R)
2. Select "والد/والدة" (Parent)
3. Sign up with email: `test@example.com`, password: `Test123!`
4. View dashboard
5. Tap "إضافة طفل" to add a child

---

## 🎯 What You Should See

### ✅ Working Features
- Beautiful splash screen with animated logo
- Smooth onboarding flow
- Surah selection with Al-Ikhlas and Ad-Duha
- Learn view with chunks and visual cards
- Two practice games (Order Chunks & Missing Segment)
- Game results with scoring
- Parent dashboard with stats
- Add child functionality

### ⚠️ Not Yet Implemented
- Audio playback (UI is ready, needs audio files)
- Recite module (placeholder only)
- Detailed results view
- Review schedule notifications
- Child progress analytics

---

## 🐛 Troubleshooting

### Problem: Build Fails
**Solution:**
- Clean build folder: `Cmd + Shift + K`
- Delete derived data: `Cmd + Shift + Option + K`
- Restart Xcode

### Problem: Can't Sign Up
**Solution:**
- Check Supabase project is running
- Verify Config.xcconfig has correct URL and key
- Check internet connection
- Look at Xcode console for error messages

### Problem: No Surahs Appear
**Solution:**
- Run seed script to populate database
- Or app will show fallback hardcoded surahs
- Check Supabase dashboard → Table Editor → surahs

### Problem: App Crashes on Launch
**Solution:**
- Check Xcode console for error
- Verify all files are included in target
- Clean and rebuild
- Try different simulator

---

## 📱 Recommended Test Devices

- **iPhone 15 Pro** (iOS 17.0+) - Best for demo
- **iPhone SE** - Test small screen
- **iPad Pro** - Test tablet layout

---

## 🎬 Demo Script

### 1. Introduction (30 seconds)
"مَعين is an interactive Quran memorization app for children using cognitive science principles: Active Recall, Spaced Repetition, and Visual Linking."

### 2. Child Flow (2 minutes)
- Show onboarding
- Select surah
- Learn a chunk (show visual cards)
- Play Order Chunks game
- Show results

### 3. Parent Flow (1 minute)
- Show parent dashboard
- Add a child
- View progress and tips

### 4. Technical Highlights (1 minute)
- SwiftUI + Supabase architecture
- Spaced repetition algorithm (SM-2)
- Beautiful Arabic-first design
- Row-level security

---

## 🎨 Key Selling Points

1. **Cognitive Science-Based**
   - Active Recall through games
   - Spaced Repetition scheduling
   - Visual memory aids

2. **Child-Friendly**
   - Gamified learning
   - Beautiful animations
   - Positive feedback

3. **Parent Transparency**
   - Progress tracking
   - Weak point identification
   - Actionable suggestions

4. **Respectful Design**
   - No AI tafsir (safe approach)
   - Verified Quran text
   - Culturally appropriate

---

## 📊 Success Metrics

After testing, you should be able to:
- ✅ Complete full onboarding flow
- ✅ Learn all chunks of a surah
- ✅ Play both practice games
- ✅ See accurate scoring
- ✅ Sign up as parent
- ✅ Add and view children
- ✅ Navigate smoothly between views

---

## 🎯 Next Steps After Testing

1. **If everything works:**
   - Add app icon
   - Record demo video
   - Prepare presentation
   - Deploy to TestFlight (optional)

2. **If issues found:**
   - Check TODO.md for known issues
   - Review SETUP_GUIDE.md for fixes
   - Check Xcode console for errors
   - Test on different simulator

---

## 💡 Pro Tips

- Use **Cmd + Shift + A** to quickly open files
- Use **Cmd + /** to comment/uncomment code
- Use **Cmd + B** to build without running
- Use **Cmd + .** to stop running app
- Use **Cmd + K** to clear console

---

## 📞 Quick Reference

### Supabase Project
- **URL:** https://ghkffyyucdffxsxolzbd.supabase.co
- **Dashboard:** https://supabase.com/dashboard/project/ghkffyyucdffxsxolzbd

### Key Files
- **Main App:** `maeem/maeemApp.swift`
- **App State:** `maeem/App/AppState.swift`
- **Supabase Service:** `maeem/Services/SupabaseService.swift`
- **Config:** `maeem/Config.xcconfig`

### Database Tables
- `profiles` - User accounts
- `children` - Child profiles
- `surahs` - Quran surahs
- `ayah_chunks` - Learning chunks
- `attempts` - Game results
- `review_schedule` - Spaced repetition

---

**Ready to memorize! 🌟**

مَعين - رفيقك في حفظ القرآن
