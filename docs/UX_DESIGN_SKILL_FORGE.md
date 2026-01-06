# Skill Forge - User Experience Design

**Version**: 1.0  
**Created**: January 6, 2026  
**Status**: Active  
**Related**: [PRODUCT_VISION_SKILL_FORGE.md](PRODUCT_VISION_SKILL_FORGE.md)

---

## 🎯 UX Vision

**Design Principle**: *"Learning should feel effortless, engaging, and rewarding."*

Skill Forge creates a seamless experience where AI-powered content generation meets intuitive learning interfaces. Users organize content around **Learning Goals**—personalized themes that make learning meaningful and contextual (e.g., "Japanese through One Piece anime"). Users move from idea to practice in seconds, with clear progress feedback and delightful interactions that encourage daily engagement.

---

## 👥 User Journey Overview

### New User Journey (First Session)
1. **Launch app** → Welcoming home screen with quick-start prompt
2. **Discover features** → Brief interactive tutorial (skippable)
3. **Generate first deck** → Guided content generation experience
4. **Practice learning** → Try flashcards with sample content
5. **See progress** → First achievement unlocked ("First Steps")

### Returning User Journey (Typical Session)
1. **Launch app** → Home dashboard shows streak, daily challenge, due cards
2. **Choose activity** → Continue deck, start new generation, or review progress
3. **Learn & practice** → Use preferred learning widget
4. **Track progress** → See stats update, badges earned, XP gained
5. **Exit satisfied** → Clear stopping point with next session preview

---

## 📱 Information Architecture

### Primary Navigation (Bottom Navigation Bar)

```
┌─────────────────────────────────────────────┐
│                                             │
│          Main Content Area                  │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
┌─────┬─────┬─────┬─────┬─────┐
│Home │Learn│Gen  │Stats│More │
└─────┴─────┴─────┴─────┴─────┘
```

**Navigation Structure**:
1. **Home** 🏠 - Dashboard, streaks, daily challenge
2. **Learn** 📚 - Browse decks, quick practice
3. **Generate** ✨ - Content creation & LLM integration
4. **Stats** 📊 - Progress, achievements, analytics
5. **More** ⚙️ - Settings, export/import, about

### Screen Hierarchy

```
Home
├── Dashboard View
├── Daily Challenge
├── Active Learning Goals
└── Recent Activity

Learn
├── Learning Goals (grouped view)
├── Goal Detail
│   └── Decks in Goal
├── All Decks (ungrouped)
├── Deck Detail
│   ├── Flashcards
│   ├── Quiz
│   ├── Spaced Repetition
│   └── Challenges
└── Search & Filter

Generate
├── New Content
│   ├── Learning Goal Selection
│   ├── Topic Selection
│   ├── Prompt Builder
│   └── Content Import
├── Provider Settings (optional)
└── Generation History

Stats
├── Overview Dashboard
├── Learning Goals Progress
├── Achievements
├── Streak Calendar
└── Detailed Analytics

More
├── Settings
├── Learning Goals Management
├── Data Export/Import
├── Dark Theme Toggle
├── TTS Settings
└── About/Help
```

---

## 🎨 Screen-by-Screen Design

### 1. Home Screen (Dashboard)

**Purpose**: Motivate daily engagement, show progress at a glance

**Layout**:
```
┌─────────────────────────────────────────┐
│  [Profile]        🔥 7-Day Streak       │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │   Today's Challenge              │  │
│  │   Learn 10 new Spanish verbs     │  │
│  │   Progress: ████░░░░  5/10       │  │
│  │   [Start Challenge]              │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Active Learning Goals                  │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece        │  │
│  │ 3 decks • 12 cards due           │  │
│  │ Progress: ████░░░░  40%          │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals          │  │
│  │ 2 decks • 5 cards due            │  │
│  │ Progress: ██░░░░░░  25%          │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Recent Achievements                    │
│  🏆 Quiz Master    🎯 7-Day Streak     │
│                                         │
│  Quick Actions                          │
│  [+ Generate Content] [📚 Browse Goals]│
└─────────────────────────────────────────┘
```

**Key Elements**:
- **Streak counter** (prominent, animated)
- **Today's challenge** (personalized, actionable)
- **Active Learning Goals** (grouped progress view)
- **Recent achievements** (visual badges)
- **Quick actions** (FAB or prominent buttons)

**Interactions**:
- Tap challenge → Start learning session
- Tap learning goal → View goal detail with all decks
- Tap achievement → View achievement detail
- Pull to refresh → Update stats

---

### 2. Generate Content Screen

**Purpose**: Make content generation effortless and intuitive

**Workflow A: No Setup (Copy/Paste)**

```
Step 1: Learning Goal & Topic Selection
┌─────────────────────────────────────────┐
│  ← Generate Content                     │
│                                         │
│  Learning Goal (optional)               │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece   [▼]  │  │
│  └─────────────────────────────────┘  │
│  [+ Create New Goal]                    │
│                                         │
│  What do you want to learn?             │
│  ┌─────────────────────────────────┐  │
│  │ Dialogue phrases from episode 5  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Popular Topics:                        │
│  [Languages] [Programming] [History]    │
│  [Science]   [Math]        [Business]   │
│                                         │
│  How many items?                        │
│  ○ 10   ● 20   ○ 50                     │
│                                         │
│  Difficulty:                            │
│  ○ Beginner  ● Intermediate  ○ Advanced │
│                                         │
│  Content Type:                          │
│  ● Flashcards  ○ Q&A  ○ Examples        │
│                                         │
│  [Generate Prompt]                      │
└─────────────────────────────────────────┘

Step 2: Share Prompt to LLM
┌─────────────────────────────────────────┐
│  ← Generate Content                     │
│                                         │
│  Your prompt is ready!                  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ Generate 20 Japanese dialogue   │  │
│  │ phrases from One Piece episode 5│  │
│  │ at intermediate level.          │  │
│  │                                 │  │
│  │ Format each as:                 │  │
│  │ Front: Japanese phrase          │  │
│  │ Back: English translation +     │  │
│  │       context from scene        │  │
│  │                                 │  │
│  │ [Copy Prompt] 📋                │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Share prompt to your LLM app:          │
│  [📤 Share to LLM App]                  │
│                                         │
│  (Android will show your installed apps)│
│                                         │
│  Or paste content if already generated: │
│  [Paste Content]                        │
└─────────────────────────────────────────┘

Step 3: Import Content
┌─────────────────────────────────────────┐
│  ← Import Content                       │
│                                         │
│  Paste LLM response here:               │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  │ (User pastes content)           │  │
│  │                                 │  │
│  │                                 │  │
│  │                                 │  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [Import]                               │
└─────────────────────────────────────────┘

Step 4: Preview & Confirm
┌─────────────────────────────────────────┐
│  ← Review Content                       │
│                                         │
│  ✓ 20 flashcards detected               │
│                                         │
│  Preview:                               │
│  ┌─────────────────────────────────┐  │
│  │ Front: 海賊王に俺はなる！       │  │
│  │ Back: I'm going to be King of   │  │
│  │       the Pirates!              │  │
│  │       (Luffy's catchphrase)     │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Front: 仲間を守る！             │  │
│  │ Back: Protect my crew!          │  │
│  │       (Episode 5, battle scene) │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Learning Goal:                         │
│  🇯🇵 Japanese - One Piece               │
│                                         │
│  Save to:                               │
│  ● New Deck: [One Piece Ep 5_____]     │
│  ○ Existing Deck: [Select Deck ▼]      │
│                                         │
│  [Add to Deck]  [Edit Content]          │
└─────────────────────────────────────────┘

Step 5: Success & Next Action
┌─────────────────────────────────────────┐
│  ✓ Content Added!                       │
│                                         │
│  20 cards added to "One Piece Ep 5"     │
│  Goal: 🇯🇵 Japanese - One Piece         │
│                                         │
│  [Start Learning]  [Generate More]      │
└─────────────────────────────────────────┘
```

**Workflow B: Automated (Provider Configured)**

```
Step 1: Same topic selection

Step 2: Automated Generation
┌─────────────────────────────────────────┐
│  ← Generating Content                   │
│                                         │
│  Using: OpenAI GPT-4                    │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  │     [Animated Loading]          │  │
│  │                                 │  │
│  │  Generating 20 Spanish verbs... │  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
└─────────────────────────────────────────┘

Step 3: Same preview & confirm
```

---

### 3. Learn Screen - Learning Goals & Decks

**Purpose**: Quick access to all learning content organized by goals

```
┌─────────────────────────────────────────┐
│  Learn                        [Search] │
│                                         │
│  View: [●Goals] [○All Decks]            │
│  Filter: [All▼] [Recent] [Due]         │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece   [▼] │  │
│  │ 3 decks • 12 due • 40% progress │  │
│  └─────────────────────────────────┘  │
│    ┌───────────────────────────────┐  │
│    │ One Piece Ep 1-5         [•••]│  │
│    │ 50 cards • 8 due              │  │
│    └───────────────────────────────┘  │
│    ┌───────────────────────────────┐  │
│    │ Japanese Grammar         [•••]│  │
│    │ 30 cards • 4 due              │  │
│    └───────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals     [▼] │  │
│  │ 2 decks • 5 due • 25% progress  │  │
│  └─────────────────────────────────┘  │
│    ┌───────────────────────────────┐  │
│    │ Python Basics            [•••]│  │
│    │ 35 cards • 3 due              │  │
│    └───────────────────────────────┘  │
│    ┌───────────────────────────────┐  │
│    │ Functions & Classes      [•••]│  │
│    │ 25 cards • 2 due              │  │
│    └───────────────────────────────┘  │
│                                         │
│  [+ Generate New Content]               │
└─────────────────────────────────────────┘
```

**Key Elements**:
- **Learning Goals** (collapsible groups with aggregate stats)
- **Deck cards** (nested under goals, show progress, due count)
- **View toggle** (Goals view or flat All Decks view)
- **Filter options** (all, recent, due cards)
- **Search** (quick find across goals and decks)
- **Context menu** (edit, export, delete)

**Interactions**:
- Tap goal header → Expand/collapse to show/hide decks
- Tap deck → Open deck detail with widget selection
- Tap [•••] → Show options (rename, export, delete, share)
- Toggle view → Switch between Goals and All Decks
- Long press → Multi-select mode
- Pull to refresh → Update due card counts

---

### 4. Deck Detail & Widget Selection

**Purpose**: Choose how to practice the deck

```
┌─────────────────────────────────────────┐
│  ← Spanish Verbs               [•••]    │
│                                         │
│  50 cards • 12 due • 80% mastered       │
│                                         │
│  How do you want to practice?           │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 📇 Flashcards                   │  │
│  │ Classic card flipping           │  │
│  │ [Practice All] [Due Cards Only] │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ ❓ Quiz                         │  │
│  │ Multiple choice & more          │  │
│  │ [Start Quiz]                    │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🔄 Spaced Repetition            │  │
│  │ Smart review based on memory    │  │
│  │ 12 cards due today              │  │
│  │ [Review Now]                    │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🎯 Challenge Mode               │  │
│  │ Timed progressive levels        │  │
│  │ [Start Challenge]               │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Deck Actions:                          │
│  [Export] [Edit Cards] [Settings]       │
└─────────────────────────────────────────┘
```

---

### 5. Learning Widget: Flashcards

**Purpose**: Classic card-flipping practice with performance tracking

```
Card Front View
┌─────────────────────────────────────────┐
│  ← Spanish Verbs            12/50  [•••]│
│                                         │
│                                         │
│                                         │
│           Hablar                        │
│                                         │
│                                         │
│           [Tap to reveal]               │
│                                         │
│                                         │
│  Progress: ████░░░░░░░░░░░░  24%        │
│                                         │
│  [Shuffle] [🔊 Speak]                   │
└─────────────────────────────────────────┘
│  [◀ Previous]  [Show Answer]  [Next ▶] │
└─────────────────────────────────────────┘

Card Back View (After Tap/Swipe)
┌─────────────────────────────────────────┐
│  ← Spanish Verbs            12/50  [•••]│
│                                         │
│  Hablar                                 │
│                                         │
│  ──────────────────                     │
│                                         │
│  To speak                               │
│                                         │
│  Example:                               │
│  "Yo hablo español"                     │
│  (I speak Spanish)                      │
│                                         │
│  How well did you know this?            │
│  [😰 Hard] [😊 Medium] [😎 Easy]        │
└─────────────────────────────────────────┘
│  [◀ Previous]  [Hide Answer]  [Next ▶] │
└─────────────────────────────────────────┘
```

**Interactions**:
- **Tap card** → Flip to reveal answer
- **Swipe left** → Next card
- **Swipe right** → Previous card
- **Swipe up** → Mark as "Easy" (optional gesture)
- **Swipe down** → Mark as "Hard" (optional gesture)
- **Tap 🔊** → Text-to-speech pronunciation
- **Tap [•••]** → Options (edit card, report issue, skip)

**Visual Feedback**:
- Smooth flip animation (300ms)
- Progress bar updates in real-time
- Button states show clearly (pressed, hover)
- Dark theme optimized colors

---

### 6. Learning Widget: Quiz Mode

**Purpose**: Active recall testing with immediate feedback

```
Quiz Question
┌─────────────────────────────────────────┐
│  ← Spanish Verbs Quiz     Question 3/10 │
│                                         │
│  What does "Comer" mean?                │
│                                         │
│  ○ To speak                             │
│  ○ To write                             │
│  ○ To eat                               │
│  ○ To run                               │
│                                         │
│  [Submit Answer]                        │
│                                         │
│  Timer: 15s    Score: 2/2 (100%)        │
└─────────────────────────────────────────┘

Correct Answer Feedback
┌─────────────────────────────────────────┐
│  ← Spanish Verbs Quiz     Question 3/10 │
│                                         │
│  ✓ Correct! +10 XP                      │
│                                         │
│  What does "Comer" mean?                │
│                                         │
│  ○ To speak                             │
│  ○ To write                             │
│  ● To eat          ← Your answer ✓      │
│  ○ To run                               │
│                                         │
│  Example: "Ella come pizza"             │
│              (She eats pizza)           │
│                                         │
│  [Next Question]                        │
│                                         │
│  Timer: 15s    Score: 3/3 (100%)        │
└─────────────────────────────────────────┘

Quiz Complete
┌─────────────────────────────────────────┐
│  Quiz Complete!           🎉            │
│                                         │
│  Spanish Verbs Quiz                     │
│                                         │
│  Score: 8/10 (80%)                      │
│  Time: 2m 15s                           │
│                                         │
│  Performance:                           │
│  ✓ Correct: 8                           │
│  ✗ Incorrect: 2                         │
│  ⏱ Avg time: 13s per question           │
│                                         │
│  +80 XP earned                          │
│  🏆 Achievement: Quiz Master (90%+)     │
│                                         │
│  [Review Mistakes] [Retry Quiz]         │
│  [Return to Deck]                       │
└─────────────────────────────────────────┘
```

**Quiz Features**:
- Multiple choice (4 options)
- True/false
- Fill-in-the-blank (typed)
- Matching pairs
- Timer (optional, configurable)

---

### 7. Stats & Progress Screen

**Purpose**: Visualize learning journey and celebrate achievements

```
┌─────────────────────────────────────────┐
│  Stats                         [Filter] │
│                                         │
│  Overview (This Week)                   │
│  ┌─────────────────────────────────┐  │
│  │ 🔥 Streak: 7 days               │  │
│  │ 📚 Cards Learned: 145           │  │
│  │ ⏱ Time Spent: 3h 24m            │  │
│  │ 🎯 Quizzes Completed: 12        │  │
│  │ ⭐ XP Earned: 1,450              │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Activity Calendar                      │
│  ┌─────────────────────────────────┐  │
│  │ Jan 2026                        │  │
│  │ M  T  W  T  F  S  S             │  │
│  │    1  2  3  4  5  6             │  │
│  │ 🟩 🟩 🟩 🟩 🟩 🟩 🟩             │  │
│  │ 7  8  9 10 11 12 13             │  │
│  │ 🟩 ⬜ ⬜ ⬜ ⬜ ⬜ ⬜             │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Achievements (15/25)                   │
│  🏆 🏆 🏆 ⭐ ⭐                         │
│  [View All Achievements]                │
│                                         │
│  Learning Goals Progress                │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece         │  │
│  │ 3 decks  ████░░░░  40%           │  │
│  │ 💻 Python Fundamentals           │  │
│  │ 2 decks  ██░░░░░░  25%           │  │
│  │ 📚 History - Ancient Rome        │  │
│  │ 1 deck   ██████░░  65%           │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Learning Insights                      │
│  • Best time: Morning (9-11am)          │
│  • Strongest: Spanish vocabulary        │
│  • Focus area: Python syntax            │
└─────────────────────────────────────────┘
```

**Charts & Visualizations**:
- Heatmap calendar (GitHub-style activity)
- Line chart (learning over time)
- Pie chart (time per deck)
- Bar chart (quiz scores)

---

### 8. Achievements Detail Screen

**Purpose**: Showcase earned badges and motivate completion

```
┌─────────────────────────────────────────┐
│  ← Achievements                15/25    │
│                                         │
│  Recently Unlocked                      │
│  ┌─────────────────────────────────┐  │
│  │      🏆                         │  │
│  │   Quiz Master                   │  │
│  │ Scored 90%+ on a quiz           │  │
│  │ Unlocked: Jan 6, 2026           │  │
│  └─────────────────────────────────┘  │
│                                         │
│  In Progress                            │
│  ┌─────────────────────────────────┐  │
│  │      ⭐                         │  │
│  │   Consistent Learner            │  │
│  │ 7-day streak                    │  │
│  │ Progress: ████████░░  7/7       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Locked                                 │
│  ┌─────────────────────────────────┐  │
│  │      🔒                         │  │
│  │   Polyglot                      │  │
│  │ Master 3 languages              │  │
│  │ Progress: ████░░░░░░  1/3       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │      🔒                         │  │
│  │   Power User                    │  │
│  │ Generate 50+ LLM cards          │  │
│  │ Progress: ██████░░░░  32/50     │  │
│  └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Achievement Categories**:
- **Practice**: Flashcard completions, quiz scores
- **Consistency**: Streaks, daily challenges
- **Content**: Cards generated, decks created
- **Mastery**: 100% completion, perfect scores
- **Community** (future): Shared decks, P2P

---

### 9. Learning Goals Management

**Purpose**: Create, edit, and organize learning goals

```
┌─────────────────────────────────────────┐
│  ← Learning Goals                       │
│                                         │
│  Your Goals (3)                         │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece        │  │
│  │ 3 decks • 100 cards              │  │
│  │ Created: Dec 15, 2025            │  │
│  │ [Edit] [Delete]                  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals          │  │
│  │ 2 decks • 60 cards               │  │
│  │ Created: Dec 20, 2025            │  │
│  │ [Edit] [Delete]                  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 📚 History - Ancient Rome       │  │
│  │ 1 deck • 28 cards                │  │
│  │ Created: Jan 2, 2026             │  │
│  │ [Edit] [Delete]                  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [+ Create New Goal]                    │
└─────────────────────────────────────────┘

Create/Edit Goal Dialog
┌─────────────────────────────────────────┐
│  Create Learning Goal                   │
│                                         │
│  Goal Name                              │
│  ┌─────────────────────────────────┐  │
│  │ Japanese through One Piece       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Icon (optional)                        │
│  🇯🇵 [📚] [💻] [🎨] [🔬] [More...]      │
│                                         │
│  Description (optional)                 │
│  ┌─────────────────────────────────┐  │
│  │ Learning Japanese using phrases │  │
│  │ and vocabulary from One Piece   │  │
│  │ anime episodes                  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [Cancel]               [Create Goal]   │
└─────────────────────────────────────────┘
```

---

### 10. Settings & More Screen

**Purpose**: Customize app behavior and manage data

```
┌─────────────────────────────────────────┐
│  ← Settings                             │
│                                         │
│  Appearance                             │
│  ┌─────────────────────────────────┐  │
│  │ Dark Theme            [●]       │  │
│  │ Follow system          [○]       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Learning                               │
│  ┌─────────────────────────────────┐  │
│  │ Text-to-Speech        [●]       │  │
│  │ Voice Speed           [1.0x ▼]  │  │
│  │ Auto-play Audio       [○]       │  │
│  │ Quiz Timer            [●]       │  │
│  │ Daily Goal            [20 cards]│  │
│  └─────────────────────────────────┘  │
│                                         │
│  LLM Integration (Optional)             │
│  ┌─────────────────────────────────┐  │
│  │ Provider              [Not Set ▼]│ │
│  │ [Configure OpenAI]              │  │
│  │ [Configure OpenRouter]          │  │
│  │ [Configure Ollama]              │  │
│  │ [Configure Portkey]             │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Data Management                        │
│  ┌─────────────────────────────────┐  │
│  │ [Export All Data]               │  │
│  │ [Import Data]                   │  │
│  │ [Backup Settings]               │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Notifications                          │
│  ┌─────────────────────────────────┐  │
│  │ Daily Reminders       [●]       │  │
│  │ Reminder Time         [9:00 AM ▼]│ │
│  │ Streak Alerts         [●]       │  │
│  └─────────────────────────────────┘  │
│                                         │
│  About                                  │
│  Version 1.0.0                          │
│  [Privacy Policy] [Help] [Feedback]     │
└─────────────────────────────────────────┘
```

---

### 11. Data Export Screen

**Purpose**: Easy export to multiple formats

```
┌─────────────────────────────────────────┐
│  ← Export Data                          │
│                                         │
│  What to export?                        │
│  ☑ All Decks                            │
│  ☑ Progress Data                        │
│  ☑ Achievements                         │
│  ☑ Settings                             │
│                                         │
│  Export Format:                         │
│  ○ CSV (Anki/Quizlet compatible)        │
│  ● JSON (Full backup)                   │
│  ○ PDF (Study guide)                    │
│  ○ HTML (Interactive)                   │
│                                         │
│  Select Decks (Optional):               │
│  ☑ Spanish Verbs                        │
│  ☑ Python Basics                        │
│  ☐ World War II                         │
│                                         │
│  [Export Now]                           │
│                                         │
│  Recent Exports:                        │
│  • backup_2026-01-06.json (2.3 MB)     │
│  • spanish_export.csv (156 KB)         │
└─────────────────────────────────────────┘
```

---

## 🎮 Gamification Elements

### Visual Feedback System

**Achievement Unlocked Animation**:
```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│           🎉 Achievement! 🎉           │
│                                         │
│               🏆                        │
│          Quiz Master                    │
│                                         │
│       Scored 90%+ on a quiz!            │
│          +100 XP Bonus                  │
│                                         │
│          [Awesome!]                     │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

**Streak Warning (End of Day)**:
```
┌─────────────────────────────────────────┐
│  🔥 Don't Break Your Streak!            │
│                                         │
│  You have 2 hours left to practice      │
│  and maintain your 7-day streak!        │
│                                         │
│  [Practice Now] [Remind Me Later]       │
└─────────────────────────────────────────┘
```

**Level Up Animation**:
```
┌─────────────────────────────────────────┐
│                                         │
│              ⭐ Level Up! ⭐            │
│                                         │
│              Level 5                    │
│                                         │
│          New Feature Unlocked:          │
│         Progressive Challenges          │
│                                         │
│          [Continue Learning]            │
│                                         │
└─────────────────────────────────────────┘
```

### XP & Progress Indicators

**XP Bar (Always Visible)**:
```
Level 4  ████████░░░░░░░░  1,450 / 2,000 XP  Level 5
```

**Card Completion Celebration**:
```
┌─────────────────────────────────────────┐
│  🎊 Deck Completed! 🎊                  │
│                                         │
│  Spanish Verbs                          │
│  50/50 cards mastered                   │
│                                         │
│  +250 XP                                │
│  🏆 Deck Master Badge                   │
│                                         │
│  [Start New Deck] [Review Deck]         │
└─────────────────────────────────────────┘
```

---

## 🎯 Key User Flows

### Flow 1: First-Time Content Generation (Copy/Paste)

```
1. Home Screen
   ↓ Tap [+ Generate Content]
2. Generate Screen → Learning Goal & Topic Selection
   ↓ Tap [+ Create New Goal]
   ↓ Enter "Japanese - One Piece" with 🇯🇵 icon
   ↓ Enter topic "Dialogue from Episode 5", 20 items, Intermediate
   ↓ Tap [Generate Prompt]
3. Prompt Ready → Share to LLM
   ↓ Tap [📤 Share to LLM App] (Android Intent picker appears)
   ↓ User selects ChatGPT from Android share menu
   User: Pastes prompt in ChatGPT
   ChatGPT: Returns structured content
   User: Copies response
   ↓ Returns to Skill Forge
4. Paste Content Screen
   ↓ Pastes ChatGPT response
   ↓ Tap [Import]
5. Preview Screen → 20 cards detected
   ↓ Shows Goal: 🇯🇵 Japanese - One Piece
   ↓ Names deck "One Piece Ep 5"
   ↓ Tap [Add to Deck]
6. Success Screen
   ↓ Tap [Start Learning]
7. Deck Detail → Widget Selection
   ↓ Tap [Flashcards - Practice All]
8. Flashcard Learning Session
   ↓ Practice cards, mark difficulty
   ↓ Complete session
9. Session Summary
   ↓ XP earned, progress updated
   ↓ Achievement: "First Steps" unlocked
   ↓ Learning Goal progress updated: 40% → 50%
```

**Time Estimate**: 3-5 minutes

---

### Flow 2: Automated Generation (Provider Configured)

```
1. Home Screen
   ↓ Tap [+ Generate Content]
2. Generate Screen → Topic Selection
   ↓ Enter "Python functions", select 10 items, Beginner
   ↓ Tap [Generate]
3. Automated Generation
   ↓ App uses OpenAI API (configured)
   ↓ Shows loading animation
   ↓ Content generated automatically
4. Preview Screen → 10 cards detected
   ↓ Tap [Add to Deck]
5. Success Screen
   ↓ Tap [Start Learning]
6. Learning Session
```

**Time Estimate**: 1-2 minutes

---

### Flow 3: Daily Learning Routine

```
1. Home Screen
   ↓ Shows "12 cards due" on Spanish Verbs
   ↓ Tap Spanish Verbs deck card
2. Deck Detail
   ↓ Tap [Spaced Repetition - Review Now]
3. Spaced Repetition Session
   ↓ Review 12 due cards
   ↓ Mark each as Hard/Medium/Easy
   ↓ Complete session
4. Session Complete
   ↓ +120 XP earned
   ↓ Today's challenge updated: 12/20 cards
   ↓ Tap [Return to Home]
5. Home Screen
   ↓ Updated stats, streak intact
```

**Time Estimate**: 5-10 minutes

---

### Flow 4: Export Data

```
1. More Screen
   ↓ Tap [Data Management]
2. Data Management Options
   ↓ Tap [Export All Data]
3. Export Screen
   ↓ Select format: JSON
   ↓ Select decks: All
   ↓ Tap [Export Now]
4. File Save Dialog
   ↓ Choose location
   ↓ Save file
5. Export Success
   ↓ Confirmation message
   ↓ File location shown
```

**Time Estimate**: 30 seconds

---

## ♿ Accessibility Features

### Visual Accessibility
- **High Contrast Mode**: Enhanced color contrast in dark theme
- **Font Scaling**: Respects system font size settings
- **Large Touch Targets**: Minimum 48dp tap areas
- **Clear Visual Hierarchy**: Proper heading structure

### Auditory Accessibility
- **Text-to-Speech**: All card content, quiz questions, answers
- **Voice Speed Control**: Adjustable TTS speed
- **Audio Feedback**: Optional sound effects for actions

### Motor Accessibility
- **Gesture Alternatives**: Buttons available for all swipe actions
- **Voice Input**: Speech-to-text for content entry
- **Keyboard Navigation**: Full keyboard support (future)

### Cognitive Accessibility
- **Simple Navigation**: Clear, consistent UI patterns
- **Progress Indicators**: Always visible
- **Undo Actions**: Easy mistake recovery
- **Consistent Layout**: Predictable screen structure

### Screen Reader Support
- **Semantic HTML/Widgets**: Proper ARIA labels (if web)
- **Descriptive Labels**: All buttons clearly labeled
- **Content Descriptions**: Images have alt text
- **Focus Management**: Logical tab order

---

## 📱 Responsive Design Considerations

### Portrait Orientation (Primary)
- Optimized for one-handed use
- Bottom navigation reachable by thumb
- FAB in comfortable reach zone
- Cards sized for readability

### Landscape Orientation
- Two-column layout for cards (when beneficial)
- Side navigation option
- Wider card display area
- Optimize for tablets

### Different Screen Sizes
- **Small phones** (< 5"): Single column, compact spacing
- **Regular phones** (5-6"): Standard layout
- **Large phones** (> 6"): Slightly larger text, more whitespace
- **Tablets** (> 7"): Two-column layouts, split views

---

## 🎨 Visual Design Language

### Color Palette (Dark Theme Default)

**Primary Colors**:
- Primary: `#6366F1` (Indigo) - Buttons, links, highlights
- Secondary: `#8B5CF6` (Purple) - Accents, achievements
- Success: `#10B981` (Green) - Correct answers, streaks
- Warning: `#F59E0B` (Amber) - Due cards, alerts
- Error: `#EF4444` (Red) - Incorrect, delete actions

**Background Colors**:
- Background: `#0F172A` (Dark Blue-Gray)
- Surface: `#1E293B` (Lighter Blue-Gray)
- Card: `#334155` (Card background)

**Text Colors**:
- Primary: `#F1F5F9` (Near white)
- Secondary: `#CBD5E1` (Light gray)
- Disabled: `#64748B` (Muted gray)

### Typography
- **Headings**: Inter Bold, 24-32sp
- **Body**: Inter Regular, 16-18sp
- **Captions**: Inter Medium, 12-14sp
- **Monospace**: Fira Code (for code examples)

### Spacing System (8dp Grid)
- XS: 4dp
- S: 8dp
- M: 16dp
- L: 24dp
- XL: 32dp
- XXL: 48dp

### Border Radius
- Small: 8dp (buttons, tags)
- Medium: 12dp (cards, inputs)
- Large: 16dp (modals, sheets)

### Elevation & Shadows
- Level 1: Cards on surface
- Level 2: Floating action buttons
- Level 3: Modals, dialogs
- Level 4: Navigation drawer

---

## 🔄 Animations & Transitions

### Micro-interactions
- **Card Flip**: 300ms ease-in-out
- **Button Press**: Scale 0.95 + ripple effect
- **Achievement Unlock**: Bounce + fade in
- **XP Gain**: Number count-up animation
- **Streak Fire**: Flickering animation

### Screen Transitions
- **Navigation**: Slide (250ms)
- **Modal**: Fade + scale (200ms)
- **Bottom Sheet**: Slide up (300ms)

### Loading States
- **Content Generation**: Pulsing dots or spinner
- **Data Import**: Progress bar
- **Deck Loading**: Skeleton cards

---

## 📊 Empty States

### No Decks Yet
```
┌─────────────────────────────────────────┐
│                                         │
│              📚                         │
│                                         │
│      Start Your Learning Journey        │
│                                         │
│  Generate your first deck and begin     │
│  mastering new skills today!            │
│                                         │
│      [+ Generate First Deck]            │
│                                         │
└─────────────────────────────────────────┘
```

### No Due Cards
```
┌─────────────────────────────────────────┐
│              ✓                          │
│                                         │
│         All Caught Up!                  │
│                                         │
│  No cards due right now. Great work!    │
│  Check back tomorrow.                   │
│                                         │
│  [Practice More] [Generate Content]     │
└─────────────────────────────────────────┘
```

### Search No Results
```
┌─────────────────────────────────────────┐
│              🔍                         │
│                                         │
│       No decks found                    │
│                                         │
│  Try a different search term or         │
│  generate a new deck.                   │
│                                         │
│      [Clear Search]                     │
└─────────────────────────────────────────┘
```

---

## 🚨 Error Handling

### Network Error (Provider API)
```
┌─────────────────────────────────────────┐
│  ⚠️ Connection Error                    │
│                                         │
│  Unable to connect to OpenAI.           │
│  Please check your connection or        │
│  use copy/paste workflow.               │
│                                         │
│  [Try Again] [Use Copy/Paste]           │
└─────────────────────────────────────────┘
```

### Import Parse Error
```
┌─────────────────────────────────────────┐
│  ⚠️ Format Not Recognized               │
│                                         │
│  We couldn't parse the pasted content.  │
│  Please check the format or try         │
│  generating a new prompt.               │
│                                         │
│  [Edit Content] [Generate New Prompt]   │
└─────────────────────────────────────────┘
```

### Streak About to Break
```
┌─────────────────────────────────────────┐
│  🔥 Streak Alert!                       │
│                                         │
│  Only 1 hour left to keep your          │
│  7-day streak alive!                    │
│                                         │
│  Practice just 1 card to maintain it.   │
│                                         │
│  [Quick Practice]  [Dismiss]            │
└─────────────────────────────────────────┘
```

---

## 🎯 Success Metrics for UX

### Engagement Metrics
- **Time to First Card**: < 3 minutes from app launch
- **Session Duration**: Average 15+ minutes
- **Return Rate**: 70%+ users return next day
- **Widget Usage**: Users try 3+ widget types in first week

### Usability Metrics
- **Task Completion**: 95%+ complete content generation flow
- **Error Rate**: < 5% on content import
- **Navigation Efficiency**: < 3 taps to any major feature
- **Help/Support Requests**: < 2% users need help

### Satisfaction Metrics
- **Net Promoter Score**: 50+
- **User Ratings**: 4.5+ stars
- **Feature Satisfaction**: 80%+ satisfied with core features
- **Accessibility Score**: AAA WCAG compliance

---

## 🔮 Future UX Enhancements (Post-MVP)

### Phase 2 Features
- **Collaborative Decks**: Share with friends via P2P
- **Voice Learning**: Audio-only practice mode
- **Smart Scheduling**: AI-optimized review times
- **Custom Widgets**: User-created learning formats

### Phase 3 Features
- **Social Features**: Friend challenges, leaderboards
- **Theme Customization**: User-defined color schemes
- **Widget Gallery**: Community-created widgets
- **Advanced Analytics**: Learning pattern insights

---

## 📝 Design Principles Summary

1. **Simplicity First**: Core actions in < 3 taps
2. **Feedback Always**: Every action gets visual response
3. **Progress Visible**: Users always see their progress
4. **Dark Theme Default**: OLED-optimized for evening study
5. **Accessible by Design**: All users can learn effectively
6. **Delight in Details**: Micro-animations make it fun
7. **Data Respect**: User owns and controls everything
8. **Performance Matters**: < 1s load, < 200ms transitions

---

**Document Status**: Ready for prototype development  
**Next Steps**: Create high-fidelity mockups and interactive prototype  
**Review Date**: February 2026
