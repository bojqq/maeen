# مَعين (Ma'een) - TODO List

## 🎯 MVP Completion (Before Demo)

### Critical (Must Have)
- [ ] **Test Database Connection**
  - Run Supabase migrations
  - Seed initial data
  - Test signup/signin flow
  - Verify data fetching works

- [ ] **Add Sample Audio** (Optional but Nice)
  - Download 1-2 surah recitations
  - Add to `Resources/Audio/`
  - Test audio playback in LearnView
  - Or skip and demo without audio

- [ ] **Test Complete User Flow**
  - Child onboarding → Learn → Practice → Results
  - Parent signup → Add child → View dashboard
  - Fix any crashes or UI issues

### Important (Should Have) - ✅ COMPLETED
- [x] **Implement Recite View** (Simplified)
  - ✅ Created `ReciteView.swift` in `Features/Recite/`
  - ✅ Word-by-word reveal challenge
  - ✅ Recording button UI (placeholder for STT)
  - ✅ Connected from home screen

- [x] **Results View** (Basic)
  - ✅ GameResultView implemented and shared across all games
  - ✅ Shows score with progress circle
  - ✅ Displays feedback based on performance
  - ✅ Retry and continue options

- [x] **Connect Review Schedule**
  - ✅ Added "Due for Review" section on home screen
  - ✅ Highlights chunks that need review
  - ✅ Uses SchedulerService SM-2 algorithm
  - ✅ Games save attempts and update review schedule

- [x] **Level Check Assessment**
  - ✅ Created LevelCheckView with 3 question types
  - ✅ Recognition, completion, and ordering questions
  - ✅ Determines beginner/intermediate/advanced level
  - ✅ Integrated into onboarding flow

- [x] **Loading and Error States**
  - ✅ Created StateViews.swift with reusable components
  - ✅ Skeleton loading views for better UX
  - ✅ Empty state views
  - ✅ Error banners with dismiss option
  - ✅ Pull-to-refresh on HomeView

### Nice to Have
- [ ] **App Icon**
  - Design simple icon with Ma'een logo
  - Add to Assets.xcassets
  - Test on device

- [ ] **Error Handling**
  - Add error alerts for network issues
  - Handle empty states gracefully
  - Show loading states

- [ ] **Polish Animations**
  - Smooth transitions between views
  - Haptic feedback on buttons
  - Celebration animations on success

---

## 🚀 Post-MVP Enhancements

### Phase 1: Core Features
- [ ] Full Recite Module with STT
- [ ] More surahs (Juz Amma)
- [ ] Offline mode
- [ ] Push notifications for reviews
- [ ] Parent-child account linking

### Phase 2: Engagement
- [ ] Achievements & badges
- [ ] Streak tracking
- [ ] Daily goals
- [ ] Progress sharing
- [ ] Leaderboards (optional)

### Phase 3: Content
- [ ] More visual themes for chunks
- [ ] Multiple reciters
- [ ] Tajweed highlighting
- [ ] Translation (optional)
- [ ] Tafsir notes (carefully curated)

### Phase 4: Platform
- [ ] iPad optimization
- [ ] macOS app
- [ ] Apple Watch companion
- [ ] Widget support
- [ ] Siri shortcuts

---

## 🐛 Known Bugs to Fix

1. **Navigation Issues**
   - [ ] Back button behavior in some views
   - [ ] Deep linking not working
   - [ ] State not persisting on app restart

2. **UI Polish**
   - [ ] Arabic text alignment in some cards
   - [ ] Keyboard dismissal on scroll
   - [ ] Loading states missing in some views

3. **Data Issues**
   - [ ] Attempts not saving to database
   - [ ] Review schedule not updating
   - [ ] Child progress not calculating correctly

---

## 📝 Code Quality

- [ ] Add comments to complex functions
- [ ] Extract magic numbers to constants
- [ ] Add unit tests for SchedulerService
- [ ] Add UI tests for critical flows
- [ ] Document API endpoints
- [ ] Add error logging

---

## 🎨 Design Improvements

- [ ] Consistent spacing across all views
- [ ] Better empty states
- [ ] Loading skeletons
- [ ] Error state illustrations
- [ ] Success animations
- [ ] Onboarding tutorial

---

## 📱 Device Testing

- [ ] iPhone SE (small screen)
- [ ] iPhone 15 Pro (standard)
- [ ] iPhone 15 Pro Max (large)
- [ ] iPad (landscape mode)
- [ ] Dark mode (already default)
- [ ] Light mode (if needed)
- [ ] Accessibility (VoiceOver)
- [ ] Right-to-left layout

---

## 🔒 Security & Privacy

- [ ] Review RLS policies
- [ ] Add rate limiting
- [ ] Sanitize user inputs
- [ ] Add privacy policy
- [ ] GDPR compliance (if EU users)
- [ ] Data export feature
- [ ] Account deletion

---

## 📊 Analytics (Optional)

- [ ] Track user engagement
- [ ] Monitor game completion rates
- [ ] Identify drop-off points
- [ ] A/B test features
- [ ] Crash reporting

---

## 🌍 Localization

- [ ] Full Arabic translation
- [ ] English translation
- [ ] Urdu (optional)
- [ ] French (optional)
- [ ] Malay (optional)

---

## 📚 Documentation

- [ ] API documentation
- [ ] Architecture diagram
- [ ] Database schema diagram
- [ ] User guide
- [ ] Parent guide
- [ ] Video tutorials

---

## Priority Matrix

### Do First (High Impact, Low Effort)
1. Test database connection
2. Fix critical bugs
3. Add app icon
4. Test complete flow

### Do Next (High Impact, High Effort)
1. Implement Recite view
2. Add more surahs
3. Connect review schedule
4. Add audio files

### Do Later (Low Impact, Low Effort)
1. Polish animations
2. Add haptic feedback
3. Improve empty states
4. Add loading skeletons

### Do Last (Low Impact, High Effort)
1. iPad optimization
2. macOS app
3. Advanced analytics
4. Multiple languages

---

**Focus on getting the MVP working perfectly before adding new features!**
