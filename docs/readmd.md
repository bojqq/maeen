# مَعين (Ma’een) — Quran Memorization MVP (SwiftUI + Supabase)

> **مَعين** هو تطبيق تعلّم تفاعلي يساعد الأطفال على حفظ القرآن بأسلوب حديث مبني على مبادئ علم التعلّم (الاسترجاع النشط + التكرار المتباعد + الربط البصري)، مع **معلّم ذكي** يوجّه رحلة الحفظ، ولوحة متابعة للوالدين.

---

## ✨ What we’re building (MVP for Hackathon)

**Goal:** Deliver a polished, measurable MVP that proves:
1) حفظ أسرع وأكثر ثباتًا عبر التفاعل بدل التلقين  
2) رحلة ممتعة للأطفال + شفافة للوالدين  
3) نظام ذكي للتدرّج والمراجعة (Spaced Repetition) بدون أي مخاطرة دينية في “تفسير” الآيات

> **Important:** في هذا الـMVP، “الذكاء الاصطناعي” يعمل كـ **Coach للحفظ** (تذكير، خطة مراجعة، متابعة الأخطاء) وليس مفسّرًا لمعاني الآيات.

---

## 🎯 Problem

الأطفال يواجهون صعوبة في الاستمرارية بسبب:
- الملل من التكرار التقليدي
- عدم وجود تغذية راجعة ذكية
- ضعف المتابعة من الأسرة
- غياب قياس واضح للتقدّم

---

## ✅ Solution

مَعين يحوّل الحفظ إلى تجربة تفاعلية عبر:
- **مصحف تفاعلي** + **خريطة ذهنية رمزية** للمقاطع
- ألعاب قصيرة تثبّت الحفظ عبر **Active Recall**
- نظام مراجعة يعتمد **Spaced Repetition**
- لوحة والدين تعرض تقدّم الطفل ونقاط الضعف
- “مَعين” (AI Coach) يرسل تذكيرات وخطة يومية حسب الأداء

---

## 🧠 Learning Principles (Backed by Cognitive Science)

- **Active Recall:** أسئلة واختبارات قصيرة بدل قراءة طويلة
- **Spaced Repetition:** جدولة مراجعات ذكية لتقليل النسيان
- **Visual Linking:** رموز مجردة/ألوان تربط المقاطع لتقوية الذاكرة
- **Small wins:** جلسات قصيرة + إنجازات تعزز الاستمرارية

---

## 🕌 Religious & Content Safety (Non-negotiables)

To respect Quran sanctity and avoid controversy:
- No AI-generated **tafsir** or meaning explanations.
- Visuals are **symbolic / abstract** (no depiction that implies interpretation).
- Quran text is from a **verified source** and stored carefully.
- Feedback language is respectful: “needs review” instead of harsh “wrong”.

---

## 🧭 App Flow (User Journey)

### 1) Onboarding
- Choose role: **Parent / Child**
- Create profile (child age + level)
- Pick **1 short Surah** for MVP (e.g., Al-Duha / Al-A’la / Al-Ikhlas)

### 2) Level Check (Quick Assessment)
- Small quiz: recognition + ordering (fast)
- App decides starting difficulty:
  - Beginner / Intermediate / Advanced

### 3) Learn (Visual Lesson)
- Surah split into **chunks** (1–3 ayat)
- Each chunk has:
  - **Abstract icon + color**
  - Audio playback (optional)
  - “focus highlight” in interactive mushaf

### 4) Practice (2 Games Only — but excellent)
**Game A: Order the Chunks**
- Drag & drop chunks in correct sequence

**Game B: Missing Segment**
- Show ayah with a missing part
- Multiple-choice fill (3 options)

> These two games prove Active Recall + reduce boredom.

### 5) Recite (MVP Mode Options)
- **Option 1 (Safe MVP):** “Next word / next chunk” recall challenge + timing
- **Option 2 (Bonus):** Audio recording + cloud STT + text comparison (if stable)

### 6) Results + Spaced Repetition Plan
- Show:
  - Accuracy score
  - Weakest chunk(s)
  - Next review schedule (today / tomorrow / 3 days / 7 days)

### 7) Parent Dashboard
- Child progress overview
- Consistency streak
- Weak points
- Suggested parent action: “Review chunk 2 with child today”

---

## 🧱 Tech Stack

### Frontend (iOS)
- **SwiftUI** — fast UI iteration, smooth animations, Arabic-friendly UI
- **AVFoundation** — recording, playback (recitation + learning audio)
- **Combine** (optional) — reactive state handling

### Backend
- **Supabase**
  - Auth (Parent / Child)
  - Postgres DB (progress, attempts, review schedule)
  - Storage (audio recordings, if needed)
  - Edge Functions (optional): scoring, recommendations

### AI / “Smart Coach” (MVP-Safe)
- **Adaptive logic (local)**:
  - spaced repetition scheduling
  - weakness detection
  - reminders logic
- Optional cloud AI later (strict guardrails)

### Optional (Bonus) Speech Recognition
- Cloud STT API (only if reliable for Arabic in demo)
- Otherwise keep “recite” as structured recall challenges

---
App theme 

	•	Background purple: #463853
	•	Main white (logo): #FFFFFF
	•	Orange stripe: #C96B48
	•	Amber stripe: #DB8B45
	•	Gold stripe: #D8B05A
	•	Soft white highlight (slight tint): #F1E8EC

---

## 🔑 Environment Variables (Secrets)

Create a `.xcconfig` or use Xcode build settings (avoid hardcoding):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Optional:
- `STT_API_KEY` (if using speech-to-text in demo)

---

## 🗃️ Database Design (Supabase)

### Tables

#### `profiles`
- `id` (uuid, PK, = auth.user.id)
- `role` (parent/child)
- `name` (text)
- `created_at`

#### `children`
- `id` (uuid, PK)
- `parent_id` (uuid, FK -> profiles.id)
- `age` (int)
- `level` (text)

#### `surahs`
- `id` (int, PK)
- `name_ar` (text)
- `name_en` (text)

#### `ayah_chunks`
- `id` (uuid, PK)
- `surah_id` (int)
- `chunk_index` (int)
- `ayah_start` (int)
- `ayah_end` (int)
- `display_text` (text)  // verified Quran text
- `visual_key` (text)    // icon key / theme color key

#### `attempts`
- `id` (uuid, PK)
- `child_id` (uuid)
- `chunk_id` (uuid)
- `activity_type` (order_game / missing_segment / recite)
- `score` (float)
- `mistakes` (jsonb)
- `created_at`

#### `review_schedule`
- `id` (uuid, PK)
- `child_id` (uuid)
- `chunk_id` (uuid)
- `next_review_at` (timestamp)
- `interval_days` (int)
- `ease_factor` (float)

---

## 🧩 Core Modules (Suggested Structure)

Ma’een/
App/
Features/
Auth/
Onboarding/
Learn/
Practice/
Recite/
Results/
ParentDashboard/
Services/
SupabaseService.swift
AudioService.swift
SchedulerService.swift
Models/
UI/
Components/
Theme/