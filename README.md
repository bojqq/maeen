# مَعين (Ma'een) - Quran Memorization App

<div align="center">

![Ma'een Logo](https://img.shields.io/badge/مَعين-Quran_Memorization-D8B05A?style=for-the-badge)
![Platform](https://img.shields.io/badge/iOS-17.0+-463853?style=for-the-badge&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-C96B48?style=for-the-badge&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-DB8B45?style=for-the-badge)

**رفيقك في حفظ القرآن الكريم**

An interactive Quran memorization app for children using cognitive science principles

[Features](#-features) • [Tech Stack](#-tech-stack) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📖 About

**مَعين (Ma'een)** transforms Quran memorization into an engaging, scientifically-backed learning experience for children. Built on proven cognitive science principles:

- **Active Recall** - Interactive games instead of passive reading
- **Spaced Repetition** - Smart review scheduling using SM-2 algorithm
- **Visual Linking** - Abstract icons and colors to strengthen memory
- **Positive Reinforcement** - Encouraging feedback and progress tracking

### Why Ma'een?

Traditional memorization methods often lead to:
- ❌ Boredom from repetitive recitation
- ❌ Lack of engagement and motivation
- ❌ No systematic review schedule
- ❌ Limited parental visibility

Ma'een solves these with:
- ✅ Gamified learning experience
- ✅ Intelligent review scheduling
- ✅ Parent dashboard with insights
- ✅ Beautiful, child-friendly interface

---

## ✨ Features

### For Children

#### 🎓 Learn Module
- Interactive visual cards for each chunk
- Color-coded memory aids
- Audio playback support
- Progress tracking

#### 🎮 Practice Games
1. **Order the Chunks** - Drag and drop chunks in correct sequence
2. **Missing Segment** - Fill in the blank with correct word
3. **Recite Mode** - Word-by-word recall challenge

#### 📊 Progress Tracking
- Visual progress indicators
- Completion badges
- Streak tracking
- Performance analytics

### For Parents

#### 👨‍👩‍👧‍👦 Dashboard
- Overview of all children
- Individual progress tracking
- Weak point identification
- Actionable suggestions

#### 📈 Analytics
- Consistency metrics
- Time spent learning
- Areas needing review
- Success rates per activity

#### 💡 Tips & Guidance
- Best practice recommendations
- Optimal learning times
- Encouragement strategies

---

## 🛠 Tech Stack

### Frontend
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive state management
- **AVFoundation** - Audio playback and recording

### Backend
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - Row Level Security (RLS)
  - Real-time subscriptions
  - Authentication
  - Storage

### APIs
- **Quran API** - Verified Quran text and metadata
- Custom spaced repetition algorithm (SM-2)

### Architecture
- **MVVM** pattern
- **Service layer** for business logic
- **Environment objects** for state management
- **Modular feature structure**

---

## 🚀 Quick Start

### Prerequisites
```bash
# Required
- Xcode 15.0+
- iOS 17.0+ device/simulator
- Supabase account

# Optional
- Supabase CLI (for local development)
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/maeem.git
cd maeem
```

2. **Open in Xcode**
```bash
open maeem.xcodeproj
```

3. **Configure Supabase**
   - Update `maeem/Config.xcconfig` with your credentials
   - Or use the existing demo credentials

4. **Setup Database**
```bash
cd supabase
supabase link --project-ref your-project-ref
supabase db push
supabase db seed
```

5. **Build & Run**
   - Select a simulator (iPhone 15 Pro recommended)
   - Press `Cmd + R`

### First Run

1. **Test as Child:**
   - Select "طفل" (Child)
   - Create profile
   - Choose a surah
   - Start learning!

2. **Test as Parent:**
   - Select "والد/والدة" (Parent)
   - Sign up with email
   - Add children
   - View dashboard

---

## 🏗 Architecture

### Project Structure
```
maeem/
├── App/
│   ├── AppState.swift              # Global app state
│   └── Router.swift                # Navigation management
│
├── Features/
│   ├── Onboarding/                 # User onboarding flow
│   │   ├── SplashView.swift
│   │   ├── OnboardingFlow.swift
│   │   ├── ParentSetupView.swift
│   │   ├── ChildSetupView.swift
│   │   └── SurahSelectionView.swift
│   │
│   ├── Learn/                      # Learning module
│   │   ├── HomeView.swift
│   │   └── LearnView.swift
│   │
│   ├── Practice/                   # Practice games
│   │   ├── PracticeMenuView.swift
│   │   ├── OrderChunksGame.swift
│   │   └── MissingSegmentGame.swift
│   │
│   ├── Recite/                     # Recitation module
│   │   └── ReciteView.swift
│   │
│   └── ParentDashboard/            # Parent features
│       └── ParentDashboardView.swift
│
├── Services/
│   ├── SupabaseService.swift      # Backend integration
│   ├── AudioService.swift          # Audio handling
│   ├── SchedulerService.swift     # Spaced repetition
│   └── QuranAPIService.swift      # Quran data
│
├── Models/
│   └── AppModels.swift             # Data models
│
├── UI/
│   ├── Components/                 # Reusable components
│   │   ├── MaeemButton.swift
│   │   └── MaeemCard.swift
│   │
│   └── Theme/                      # Design system
│       ├── Colors.swift
│       └── Typography.swift
│
└── Resources/
    ├── Audio/                      # Audio files
    └── Icons/                      # App icons
```

### Data Flow

```
User Action → View → AppState/Service → Supabase → Database
                ↓                           ↓
            UI Update ← Published State ← Response
```

### Database Schema

```sql
profiles (id, role, name)
    ↓
children (id, parent_id, name, age, level)
    ↓
attempts (id, child_id, chunk_id, score)
    ↓
review_schedule (id, child_id, chunk_id, next_review_at)

surahs (id, name_ar, name_en)
    ↓
ayah_chunks (id, surah_id, chunk_index, display_text)
```

---

## 🎨 Design System

### Colors
```swift
Background:  #463853  // Deep purple
Primary:     #D8B05A  // Gold
Orange:      #C96B48  // Warm orange
Amber:       #DB8B45  // Amber
White:       #FFFFFF  // Pure white
Soft White:  #F1E8EC  // Tinted white
```

### Typography
- **Quran Text:** Serif, 18-32pt
- **Titles:** Rounded, Bold, 18-28pt
- **Body:** Default, Regular, 16pt
- **Captions:** Default, Regular, 14pt

### Components
- `MaeemButton` - Primary action button
- `MaeemSecondaryButton` - Secondary action
- `MaeemCard` - Content container
- `MaeemTextField` - Text input
- `SurahCard` - Surah selection
- `ChunkCard` - Chunk display

---

## 🧪 Testing

### Manual Testing
```bash
# Run tests
Cmd + U

# Test specific feature
1. Open simulator
2. Navigate to feature
3. Verify behavior
```

### Test Coverage
- ✅ Onboarding flow
- ✅ Authentication
- ✅ Learning module
- ✅ Practice games
- ✅ Parent dashboard
- ⏳ Spaced repetition (unit tests needed)
- ⏳ Audio recording (integration tests needed)

---

## 📱 Deployment

### TestFlight
1. Archive the app (`Cmd + Shift + B`)
2. Upload to App Store Connect
3. Add testers
4. Distribute

### App Store
1. Add app icons
2. Create screenshots
3. Write description
4. Submit for review

### Requirements
- [ ] App icons (all sizes)
- [ ] Screenshots (all devices)
- [ ] Privacy policy
- [ ] Support URL
- [ ] Age rating (4+)
- [ ] Keywords (Arabic & English)

---

## 🤝 Contributing

We welcome contributions! Here's how:

### Getting Started
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Guidelines
- Follow Swift style guide
- Add comments for complex logic
- Update documentation
- Test on multiple devices
- Respect religious content

### Areas for Contribution
- 🎨 UI/UX improvements
- 🐛 Bug fixes
- 📚 More surahs and content
- 🌍 Localization
- 📊 Analytics features
- 🎮 New game types
- 🔊 Audio enhancements

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Quran API** - For verified Quran text
- **Supabase** - For backend infrastructure
- **SwiftUI Community** - For inspiration and support
- **Cognitive Science Research** - For learning principles

---

## 📞 Contact

- **Email:** support@maeem.app
- **Twitter:** [@maeemapp](https://twitter.com/maeemapp)
- **Website:** [maeem.app](https://maeem.app)

---

## 🗺 Roadmap

### v1.0 (MVP) ✅
- [x] Core onboarding
- [x] Learn module
- [x] Practice games
- [x] Parent dashboard
- [x] Supabase integration

### v1.1 (Q2 2026)
- [ ] Audio recording with STT
- [ ] More surahs (Juz Amma)
- [ ] Offline mode
- [ ] Push notifications
- [ ] iPad optimization

### v1.2 (Q3 2026)
- [ ] Achievements system
- [ ] Social features
- [ ] Multiple reciters
- [ ] Tajweed highlighting
- [ ] macOS app

### v2.0 (Q4 2026)
- [ ] AI-powered recommendations
- [ ] Community features
- [ ] Teacher dashboard
- [ ] Advanced analytics
- [ ] Multi-language support

---

<div align="center">

**Built with ❤️ for the Quran memorization journey**

مَعين - رفيقك في حفظ القرآن

[⬆ Back to Top](#مَعين-maeen---quran-memorization-app)

</div>
