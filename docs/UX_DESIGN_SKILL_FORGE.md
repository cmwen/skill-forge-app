# Skill Forge - User Experience Design

**Version**: 2.0  
**Created**: January 6, 2026  
**Updated**: January 6, 2026  
**Status**: Active - Goal-Oriented Redesign  
**Related**: [PRODUCT_VISION_SKILL_FORGE.md](PRODUCT_VISION_SKILL_FORGE.md)

---

## 📋 Version 2.0 - Major Design Changes

### What Changed and Why

**Problem Identified**: The original design allowed users to generate random decks/flashcards without structure, making content hard to track and manage. Users typically have specific learning goals (e.g., learning a language, mastering a skill), but the previous design didn't properly support this goal-oriented approach.

**Key Design Decisions**:

1. **Goals are now mandatory** - Every piece of content must belong to a learning goal
   - Prevents orphaned decks and disorganized content
   - Makes it easy to track progress toward specific objectives
   - Content generation always happens in the context of a goal

2. **Removed gamification elements** - Simplified for personal learning use
   - No streaks, XP, badges, or leaderboards
   - Focus on actual learning progress (mastery %, time spent)
   - Simple milestones replace achievement systems
   - Personal tool, not a competitive platform

3. **Simplified navigation** - Reduced from 5 tabs to 4
   - **Goals** (home): View all learning goals and their progress
   - **Generate**: Create new content within a goal context
   - **Progress**: Track statistics and completion
   - **More**: Settings and data management

4. **Goal-first content generation** - Restructured workflow
   - User must select (or create) a goal before generating content
   - Goal context shown throughout the generation flow
   - Content is saved to specific decks within the goal
   - No "homeless" content possible

5. **Clearer information hierarchy**
   - Goals → Decks → Cards (three-level structure)
   - Easy to see what belongs where
   - Progress tracking at each level
   - Consistent navigation patterns

### Result

A more structured, manageable learning experience that helps users stay organized and track meaningful progress toward their personal learning objectives.

---

## 🎯 UX Vision

**Design Principle**: *"Structure your learning journey around meaningful goals."*

Skill Forge is a personal learning companion that helps users achieve their learning goals through structured, AI-generated content. The design prioritizes **Learning Goals** as the primary organizing principle—users always work within the context of what they want to achieve (e.g., "Learn Spanish for Travel", "Master Python Basics"). Content generation and practice sessions are always tied to a specific goal, ensuring learning materials are organized, trackable, and purposeful.

**Key Philosophy**:
- **Goal-first approach**: Every piece of content belongs to a goal
- **Clear structure**: Goals contain organized decks of related material
- **Progress tracking**: Easy to see advancement toward each goal
- **Personal tool**: Designed for individual learning, not competition
- **Simple & focused**: Clean interface without gamification distractions

---

## 👥 User Journey Overview

### New User Journey (First Session)
1. **Launch app** → Welcome screen prompts to create first learning goal
2. **Create learning goal** → Define what they want to learn (e.g., "Spanish for Travel")
3. **Generate first content** → AI-assisted deck creation within that goal
4. **Practice learning** → Try flashcards with generated content
5. **See structure** → Understand goals → decks → cards hierarchy

### Returning User Journey (Typical Session)
1. **Launch app** → Home shows active learning goals with progress
2. **Select goal** → Choose which goal to work on today
3. **Choose deck** → Pick specific topic within that goal
4. **Learn & practice** → Use flashcards or quiz mode
5. **Track progress** → See goal completion percentage update

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
┌───────────┬───────────┬───────────┬─────────┐
│  Goals    │  Generate │  Progress │  More   │
└───────────┴───────────┴───────────┴─────────┘
```

**Simplified Navigation Structure**:
1. **Goals** 🎯 - Learning goals, decks, practice
2. **Generate** ✨ - Content creation & import
3. **Progress** 📊 - Goal progress, statistics
4. **More** ⚙️ - Settings, export/import, help

### Screen Hierarchy

```
Goals (Home)
├── Learning Goals List
├── Goal Detail
│   ├── Decks in Goal
│   ├── Goal Settings
│   └── Goal Progress
├── Deck Detail
│   ├── Flashcard Practice
│   ├── Quiz Mode
│   └── Card Management
└── Search Goals/Decks

Generate
├── Select Learning Goal (required)
├── Topic & Parameters
├── Prompt Generation
├── Import Content (paste)
└── Preview & Confirm

Progress
├── All Goals Overview
├── Goal-Specific Progress
├── Statistics & Charts
└── Completed Items History

More
├── Goals Management
│   ├── Create/Edit Goals
│   ├── Archive Goals
│   └── Goal Templates
├── Settings
│   ├── App Preferences
│   ├── LLM Provider (optional)
│   └── Data Management
├── Export/Import Data
└── Help & About
```

---

## 🎨 Screen-by-Screen Design

### 1. Goals Screen (Home/Primary Screen)

**Purpose**: Display all learning goals with clear progress tracking

**Layout**:
```
┌─────────────────────────────────────────┐
│  My Learning Goals            [Search]  │
│                                         │
│  Active Goals                           │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece        │  │
│  │ 3 decks • 150 total cards       │  │
│  │ ████████░░░░  65% complete      │  │
│  │ Last studied: 2 hours ago       │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals          │  │
│  │ 2 decks • 85 total cards        │  │
│  │ ████░░░░░░░░  32% complete      │  │
│  │ Last studied: Yesterday         │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 🇪🇸 Spanish for Travel          │  │
│  │ 4 decks • 200 total cards       │  │
│  │ ██░░░░░░░░░░  18% complete      │  │
│  │ Last studied: 3 days ago        │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Completed Goals (2)              [▼]  │
│                                         │
│  [+ New Learning Goal]                  │
└─────────────────────────────────────────┘
```

**Key Elements**:
- **Learning goal cards** (title, icon, deck count, total cards)
- **Progress bars** (percentage of cards mastered)
- **Last studied timestamp** (helps user prioritize)
- **Completed goals section** (collapsible, archived)
- **New goal button** (prominent, easy to find)
- **Search** (find goals quickly as list grows)

**Interactions**:
- Tap goal → Open goal detail with all decks
- Long press goal → Options (edit, archive, delete, export)
- Tap "+ New Learning Goal" → Create goal flow
- Pull to refresh → Update progress stats
- Swipe goal card → Quick actions (continue learning, edit)

**Empty State** (First Launch):
```
┌─────────────────────────────────────────┐
│  Welcome to Skill Forge!                │
│                                         │
│  Start your learning journey            │
│                                         │
│  [Icon: Empty notebook]                 │
│                                         │
│  Create your first learning goal        │
│  to organize your study materials       │
│                                         │
│  Examples:                              │
│  • Learn Spanish for vacation           │
│  • Master Python basics                 │
│  • Study Japanese through anime         │
│                                         │
│  [Create Your First Goal]               │
└─────────────────────────────────────────┘
```

---

### 2. Create Learning Goal Flow

**Purpose**: Guide users to create structured, meaningful learning goals

**Step 1: Goal Details**
```
┌─────────────────────────────────────────┐
│  ← Create Learning Goal                 │
│                                         │
│  What do you want to learn?             │
│  ┌─────────────────────────────────┐  │
│  │ Spanish for Travel              │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Icon (optional)                        │
│  🇪🇸 🌍 ✈️ 📚 💼 🏠 🎵 🎮 💻 ⚽       │
│                                         │
│  Description (optional)                 │
│  ┌─────────────────────────────────┐  │
│  │ Learn conversational Spanish    │  │
│  │ for my trip to Barcelona        │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Target Completion (optional)           │
│  ┌─────────────────────────────────┐  │
│  │ 3 months           [calendar▼]  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Common Goal Templates:                 │
│  [Language] [Programming] [Academic]    │
│  [Hobby] [Professional] [Creative]      │
│                                         │
│            [Create Goal]                │
└─────────────────────────────────────────┘
```

**Step 2: Goal Created - Next Actions**
```
┌─────────────────────────────────────────┐
│  ✓ Goal Created!                        │
│                                         │
│  🇪🇸 Spanish for Travel                 │
│                                         │
│  Your goal is ready. Now let's add      │
│  some learning content.                 │
│                                         │
│  [Generate Content with AI]             │
│  Create decks using AI prompts          │
│                                         │
│  [Create Empty Deck]                    │
│  Add cards manually                     │
│                                         │
│  [Do This Later]                        │
└─────────────────────────────────────────┘
```

**Key Design Decisions**:
- **Goal name is required** (forces intentionality)
- **Icon adds personality** (makes goals memorable)
- **Description adds context** (helps user remember purpose)
- **Target date is optional** (some goals are ongoing)
- **Templates speed setup** (common goal types pre-configured)
- **Immediate next action** (guide to add content right away)---

### 3. Goal Detail Screen

**Purpose**: Show all decks within a goal, manage goal content

**Layout**:
```
┌─────────────────────────────────────────┐
│  ← 🇯🇵 Japanese - One Piece       [•••] │
│                                         │
│  Progress                               │
│  ████████░░░░  65% complete             │
│  98 / 150 cards mastered                │
│                                         │
│  Decks in this goal                     │
│  ┌─────────────────────────────────┐  │
│  │ Episode 1-5 Dialogue            │  │
│  │ 50 cards • 33 mastered          │  │
│  │ Last studied: Today             │  │
│  │               [Practice Now ▶]  │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Basic Grammar Patterns          │  │
│  │ 45 cards • 30 mastered          │  │
│  │ Last studied: Yesterday         │  │
│  │               [Practice Now ▶]  │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Character Names & Terms         │  │
│  │ 55 cards • 35 mastered          │  │
│  │ Last studied: 3 days ago        │  │
│  │               [Practice Now ▶]  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [+ Add New Deck]                       │
│  [Generate Content with AI]             │
└─────────────────────────────────────────┘
```

**Key Elements**:
- **Goal progress** (aggregated across all decks)
- **Deck list** (all decks belonging to this goal)
- **Deck progress** (individual mastery percentage)
- **Quick practice** (start learning immediately)
- **Add deck options** (manual or AI-generated)

**Goal Menu [•••]**:
- Edit goal details
- View detailed statistics
- Export all decks in goal
- Archive goal
- Delete goal

**Interactions**:
- Tap deck card → Open deck detail
- Tap "Practice Now" → Start flashcard session
- Tap "+ Add New Deck" → Create empty deck
- Tap "Generate Content" → Launch AI generation flow
- Long press deck → Options (rename, move, delete, export)

---

### 4. Generate Content Screen (Updated Flow)

**Purpose**: Generate AI content always within a learning goal context

**Step 1: Select Learning Goal (Required)**
```
┌─────────────────────────────────────────┐
│  ← Generate Content                     │
│                                         │
│  Which goal is this content for?        │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece        │  │
│  │ 3 decks • 150 cards             │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals          │  │
│  │ 2 decks • 85 cards              │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 🇪🇸 Spanish for Travel          │  │
│  │ 4 decks • 200 cards             │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [+ Create New Goal]                    │
└─────────────────────────────────────────┘

Step 2: Define Topic & Parameters
┌─────────────────────────────────────────┐
│  ← Generate Content                     │
│                                         │
│  Goal: 🇯🇵 Japanese - One Piece         │
│                                         │
│  What specific topic?                   │
│  ┌─────────────────────────────────┐  │
│  │ Dialogue from episode 10        │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Number of items                        │
│  ○ 10   ● 20   ○ 50   ○ Custom         │
│                                         │
│  Difficulty level                       │
│  ○ Beginner  ● Intermediate  ○ Advanced│
│                                         │
│  Content type                           │
│  ● Flashcards  ○ Q&A  ○ Fill-in-blank  │
│                                         │
│  Additional context (optional)          │
│  ┌─────────────────────────────────┐  │
│  │ Focus on common phrases used by │  │
│  │ Luffy and crew members          │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [Generate Prompt]                      │
└─────────────────────────────────────────┘

Step 3: Share Prompt to LLM
┌─────────────────────────────────────────┐
│  ← Generate Content                     │
│                                         │
│  Your prompt is ready!                  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ Generate 20 Japanese dialogue   │  │
│  │ phrases from One Piece episode  │  │
│  │ 10 at intermediate level.       │  │
│  │                                 │  │
│  │ Format each flashcard as:       │  │
│  │ Front: Japanese phrase (romaji) │  │
│  │ Back: English translation +     │  │
│  │       context from scene        │  │
│  │                                 │  │
│  │ Focus on phrases used by Luffy  │  │
│  │ and crew members.               │  │
│  │                                 │  │
│  │ [Copy Prompt] 📋                │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Share to your LLM app:                 │
│  [📤 Share to App]                      │
│                                         │
│  Or paste content if ready:             │
│  [Paste Content]                        │
└─────────────────────────────────────────┘

Step 4: Import Content
┌─────────────────────────────────────────┐
│  ← Import Content                       │
│                                         │
│  Paste the LLM response here:           │
│  ┌─────────────────────────────────┐  │
│  │                                 │  │
│  │ [Paste area - multi-line]       │  │
│  │                                 │  │
│  │                                 │  │
│  │                                 │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [Parse & Preview]                      │
└─────────────────────────────────────────┘

Step 5: Preview & Save
┌─────────────────────────────────────────┐
│  ← Review Content                       │
│                                         │
│  ✓ 20 flashcards detected               │
│                                         │
│  Preview:                               │
│  ┌─────────────────────────────────┐  │
│  │ Front: Kaizoku ou ni ore wa naru│  │
│  │ Back: I'm going to be King of   │  │
│  │       the Pirates!              │  │
│  │       (Luffy's signature line)  │  │
│  │                            [✓]  │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Front: Nakama                   │  │
│  │ Back: Crewmate/Friend           │  │
│  │       (Important concept in OP) │  │
│  │                            [✓]  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  [Tap cards to edit]                    │
│                                         │
│  Save to:                               │
│  Goal: 🇯🇵 Japanese - One Piece         │
│  ● New Deck: [Episode 10_______]       │
│  ○ Existing: [Select Deck ▼]           │
│                                         │
│  [Save to Goal]                         │
└─────────────────────────────────────────┘

Step 6: Success
┌─────────────────────────────────────────┐
│  ✓ Content Added!                       │
│                                         │
│  20 cards added to "Episode 10"         │
│  in goal: 🇯🇵 Japanese - One Piece      │
│                                         │
│  [Start Practicing]  [Back to Goal]     │
└─────────────────────────────────────────┘
```

**Key Design Changes**:
- **Goal selection is first step** (enforces structure)
- **Cannot generate orphan content** (everything has a home)
- **Goal context shown throughout flow** (user always knows where content goes)
- **Deck selection at end** (choose existing or create new within goal)

---

### 5. Deck Detail & Practice Selection

**Purpose**: Choose how to study a specific deck

```
┌─────────────────────────────────────────┐
│  ← Episode 1-5 Dialogue          [•••]  │
│                                         │
│  Goal: 🇯🇵 Japanese - One Piece         │
│  50 cards • 33 mastered (66%)           │
│                                         │
│  How do you want to practice?           │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 📇 Flashcards                   │  │
│  │ Classic card flipping           │  │
│  │ [Study All] [Review Unmastered] │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ ❓ Quiz Mode                    │  │
│  │ Test your knowledge             │  │
│  │ [Start Quiz]                    │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Deck contents                          │
│  [View All Cards]                       │
│                                         │
│  Statistics                             │
│  Mastery: 33/50 cards (66%)             │
│  Created: 2 weeks ago                   │
│  Last studied: Today                    │
│  Total study time: 2h 15m               │
└─────────────────────────────────────────┘
```

**Deck Menu [•••]**:
- Edit deck name
- Add cards manually
- Generate more content
- Export deck
- Move to different goal
- Delete deck

**Key Simplifications**:
- **Removed gamification widgets** (challenges, XP, streaks)
- **Simple practice modes** (flashcards and quiz only)
- **Focus on progress** (mastery percentage, not points)
- **Clear statistics** (time spent, mastery rate)
---

### 6. Progress Screen

**Purpose**: Track learning progress across all goals

```
┌─────────────────────────────────────────┐
│  Progress                    [Export]   │
│                                         │
│  Overall Statistics                     │
│  ┌─────────────────────────────────┐  │
│  │ Total study time: 24h 35m       │  │
│  │ Total cards: 435                │  │
│  │ Cards mastered: 287 (66%)       │  │
│  │ Active goals: 3                 │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Goals Progress                         │
│  ┌─────────────────────────────────┐  │
│  │ 🇯🇵 Japanese - One Piece        │  │
│  │ ████████░░░░  65% complete      │  │
│  │ 98/150 cards • 18h study time   │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 💻 Python Fundamentals          │  │
│  │ ████░░░░░░░░  32% complete      │  │
│  │ 27/85 cards • 4h study time     │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ 🇪🇸 Spanish for Travel          │  │
│  │ ██░░░░░░░░░░  18% complete      │  │
│  │ 36/200 cards • 2h 35m study     │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Recent Activity                        │
│  Today: 45 minutes                      │
│  This week: 5h 20m                      │
│  This month: 18h 15m                    │
│                                         │
│  [View Detailed Analytics]              │
└─────────────────────────────────────────┘
```

**Key Elements**:
- **Overall stats** (aggregate across all goals)
- **Goal progress bars** (visual representation)
- **Study time tracking** (per goal and total)
- **Recent activity summary** (daily, weekly, monthly)
- **Export option** (backup all data)

**Detailed Analytics View**:
```
┌─────────────────────────────────────────┐
│  ← 🇯🇵 Japanese - One Piece             │
│                                         │
│  Progress Overview                      │
│  ████████░░░░  65% complete             │
│  98/150 cards mastered                  │
│                                         │
│  Study Time                             │
│  [Bar chart showing daily activity]     │
│  Total: 18 hours                        │
│  Average: 30 min/day                    │
│                                         │
│  Mastery by Deck                        │
│  Episode 1-5: ████████░░  80%           │
│  Grammar:     ██████░░░░  60%           │
│  Characters:  ████░░░░░░  40%           │
│                                         │
│  Performance Trends                     │
│  Accuracy: 78% (↑ 5% this week)         │
│  Retention: 82%                         │
│                                         │
│  Milestones                             │
│  ✓ First 50 cards mastered              │
│  ✓ 7 days of study                      │
│  ○ 100 cards mastered (98/100)          │
└─────────────────────────────────────────┘
```

**Key Simplifications**:
- **Removed gamification** (no XP, levels, badges, streaks)
- **Focus on actual progress** (mastery %, time invested)
- **Simple milestones** (achievement markers, not rewards)
- **Clear data** (charts show trends, not competitions)

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
---

### 7. More Screen (Settings & Data Management)

**Purpose**: Customize app preferences and manage learning goals

```
┌─────────────────────────────────────────┐
│  More                                   │
│                                         │
│  Learning Goals                         │
│  ┌─────────────────────────────────┐  │
│  │ Manage Goals                    │  │
│  │ Create, edit, or archive goals  │  │
│  └─────────────────────────────────┘  │
│                                         │
│  App Settings                           │
│  ┌─────────────────────────────────┐  │
│  │ Appearance                      │  │
│  │ Dark theme • Display options    │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Learning Preferences            │  │
│  │ TTS, quiz timer, auto-play      │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ LLM Provider (Optional)         │  │
│  │ Configure API integrations      │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Data Management                        │
│  ┌─────────────────────────────────┐  │
│  │ Export All Data                 │  │
│  │ Backup your learning content    │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Import Data                     │  │
│  │ Restore from backup             │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Help & Support                         │
│  ┌─────────────────────────────────┐  │
│  │ User Guide                      │  │
│  │ Privacy Policy                  │  │
│  │ About Skill Forge               │  │
│  │ Version 1.0.0                   │  │
│  └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Settings Detail - Appearance**:
```
┌─────────────────────────────────────────┐
│  ← Appearance                           │
│                                         │
│  Theme                                  │
│  ○ Light                                │
│  ● Dark                                 │
│  ○ Follow system                        │
│                                         │
│  Display                                │
│  Font size          [Medium ▼]          │
│  Card animation     [On]                │
│  Reduce motion      [Off]               │
└─────────────────────────────────────────┘
```

**Settings Detail - Learning Preferences**:
```
┌─────────────────────────────────────────┐
│  ← Learning Preferences                 │
│                                         │
│  Audio                                  │
│  Text-to-speech     [●]                 │
│  TTS voice          [System default ▼]  │
│  Voice speed        [1.0x]              │
│  Auto-play audio    [○]                 │
│                                         │
│  Quiz                                   │
│  Enable timer       [●]                 │
│  Time per question  [30 seconds]        │
│  Shuffle questions  [●]                 │
│                                         │
│  Practice                               │
│  Cards per session  [20]                │
│  Show progress bar  [●]                 │
└─────────────────────────────────────────┘
```

**Settings Detail - LLM Provider (Optional)**:
```
┌─────────────────────────────────────────┐
│  ← LLM Provider Configuration           │
│                                         │
│  Current: Not configured                │
│  Using copy/paste workflow              │
│                                         │
│  Optional: Configure API Access         │
│  ┌─────────────────────────────────┐  │
│  │ OpenAI                          │  │
│  │ GPT-4, GPT-3.5                  │  │
│  │               [Configure >]     │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ OpenRouter                      │  │
│  │ Access multiple models          │  │
│  │               [Configure >]     │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Ollama (Local)                  │  │
│  │ Run models on device            │  │
│  │               [Configure >]     │  │
│  └─────────────────────────────────┘  │
│  ┌─────────────────────────────────┐  │
│  │ Portkey                         │  │
│  │ LLM gateway                     │  │
│  │               [Configure >]     │  │
│  └─────────────────────────────────┘  │
│                                         │
│  Note: API configuration is completely  │
│  optional. The copy/paste workflow      │
│  works with any LLM without setup.      │
└─────────────────────────────────────────┘
```
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

### Import Parse Error
```
┌─────────────────────────────────────────┐
│  ⚠️ Format Not Recognized               │
│                                         │
│  We couldn't parse the pasted content.  │
│  Please check the format and try again. │
│                                         │
│  [Edit Content] [Try Again]             │
└─────────────────────────────────────────┘
```

### Network Error (Optional API)
```
┌─────────────────────────────────────────┐
│  ⚠️ Connection Error                    │
│                                         │
│  Unable to connect to API provider.     │
│  Please check your connection or use    │
│  the copy/paste workflow instead.       │
│                                         │
│  [Try Again] [Use Copy/Paste]           │
└─────────────────────────────────────────┘
```

### Empty Goal State
```
┌─────────────────────────────────────────┐
│  🎯 Goal Created!                       │
│                                         │
│  Your goal has no content yet.          │
│  Generate some learning materials       │
│  to get started.                        │
│                                         │
│  [Generate Content] [Add Manual Deck]   │
└─────────────────────────────────────────┘
```

---

## 🎯 Success Metrics for UX

### Engagement Metrics
- **Time to First Card**: < 3 minutes from app launch
- **Content Organization**: 100% of content belongs to a goal
- **Session Duration**: Average 15+ minutes
- **Return Rate**: 70%+ users return next day

### Usability Metrics
- **Task Completion**: 95%+ complete content generation flow
- **Navigation Efficiency**: < 3 taps to any major feature
- **Goal Adoption**: 90%+ users create at least one goal
- **Error Rate**: < 5% on content import

### Satisfaction Metrics
- **User Ratings**: 4.5+ stars
- **Feature Satisfaction**: 80%+ satisfied with core features
- **Accessibility Score**: AA WCAG compliance (AAA target)
- **Data Control**: 100% data export success rate

---

## 📝 Design Principles Summary

### Core Principles

1. **Goal-Oriented Structure**
   - Every piece of content must belong to a learning goal
   - Goals provide context and purpose for all learning activities
   - Clear hierarchy: Goals → Decks → Cards

2. **Simplicity Over Gamification**
   - Personal learning tool, not a game
   - Progress measured by actual mastery, not points
   - No streaks, XP, or competitive elements
   - Focus on meaningful learning outcomes

3. **User Ownership & Privacy**
   - All data stored locally on device
   - Easy export at any time
   - No account required, no cloud lock-in
   - User controls all content and data

4. **Flexible Content Generation**
   - Works with any LLM via copy/paste (no setup needed)
   - Optional API integration for power users
   - Clear, structured prompts guide content creation
   - Content always saved within goal context

5. **Accessible & Inclusive**
   - High contrast, readable fonts
   - Text-to-speech support
   - Keyboard navigation
   - Dark theme optimized for evening study

6. **Performance Focused**
   - Fast app launches (< 1s)
   - Smooth animations (< 200ms transitions)
   - Efficient data storage
   - Minimal battery impact

---

## 🔮 Future Enhancements (Post-MVP)

### Potential Phase 2 Features
- **Smart review scheduling**: Suggest optimal study times based on user patterns
- **Deck templates**: Pre-configured goal and deck structures for common topics
- **Audio-only mode**: Practice while commuting or exercising
- **Batch operations**: Edit/delete multiple cards at once
- **Advanced search**: Filter by mastery level, date created, etc.

### Potential Phase 3 Features
- **Deck sharing**: Export/import decks between users
- **Voice input**: Create cards by speaking
- **Image support**: Add images to flashcards
- **Widget themes**: Customize flashcard appearance

---

## ✅ Readiness Checklist

### Design Complete
- [x] Information architecture defined
- [x] All core screens designed
- [x] User flows documented
- [x] Error states considered
- [x] Empty states designed
- [x] Accessibility requirements specified

### Ready for Development
- [x] Screen hierarchy clear
- [x] Navigation patterns established
- [x] Data structure implied by UI
- [x] Key interactions specified
- [x] Success metrics defined

### Next Steps for Implementation
1. Create Flutter screen widgets based on designs
2. Implement database schema for Goals → Decks → Cards
3. Build content generation flow with LLM integration
4. Develop flashcard and quiz practice widgets
5. Add progress tracking and statistics
6. Implement data export/import features

---

**Document Status**: Ready for Development (Version 2.0)  
**Last Updated**: January 6, 2026  
**Design Owner**: Experience Designer Team  
**Next Review**: After MVP release

---

## 📋 Change Log

### Version 2.0 (January 6, 2026)
- **Major redesign**: Goal-oriented structure
- **Removed**: Gamification elements (streaks, XP, badges, challenges)
- **Simplified**: Navigation from 5 to 4 tabs
- **Added**: Mandatory learning goals for all content
- **Improved**: Content generation workflow with goal context
- **Clarified**: Personal learning focus vs. competitive features

### Version 1.0 (Initial)
- Initial UX design with gamification
- 5-tab navigation structure
- Optional learning goals
- Achievement system
