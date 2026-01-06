# Skill Forge - Product Vision Document

**Version**: 1.0  
**Created**: January 6, 2026  
**Status**: Active  
**Owner**: Product Team  

---

## 🎯 Product Vision Statement

**Skill Forge** is a privacy-first, AI-powered learning companion for Android that transforms how people acquire new skills and languages. By integrating local LLMs (Ollama), personalized learning content, and engaging gamified experiences, Skill Forge enables users to learn at their own pace with full ownership and control of their data.

**Tagline**: *"Learn Smarter. Own Your Data. Master Any Skill."*

---

## 💡 Core Value Proposition

### For Learners
- **AI-Powered Content Generation**: Generate personalized learning material for any topic using your favorite LLM (ChatGPT, Gemini, Claude, local Ollama—your choice)
- **Learning Material Orchestration**: Skill Forge intelligently guides you through content generation with structured prompts, then organizes everything into engaging learning experiences
- **Complete Data Ownership**: Your learning data stays on your device. No account required. No cloud lock-in. Easy export anytime.
- **Engaging Learning Formats**: Interactive flashcards, spaced-repetition quizzes, and progressive challenges that make learning stick
- **Gamified Progress**: Earn badges, streaks, and achievements to stay motivated
- **Accessibility**: Text-to-speech support, dark theme, and high-performance UI for all users

### For App
- **Production-Ready Foundation**: Built on the skill-forge Flutter template with AI-powered development workflow
- **Extensible Architecture**: Easy to add new learning widgets, content formats, and features
- **Ollama Integration**: Seamless local LLM integration for content generation and adaptive learning

---

## 📱 Product Features

### 1. **Content Generation & Collection**
**Primary Goal**: Enable users to generate personalized learning material for any topic

- **Smart Content Generation Workflow**
  - Skill Forge generates prompts for your chosen topic and learning goal
  - Share the prompt to your favorite LLM app (ChatGPT, Gemini, Claude, local Ollama)
  - Receive structured learning content (flashcards, Q&A, examples)
  - Paste results directly back into Skill Forge
  - App automatically organizes into learning decks

- **Multiple LLM Support**
  - Work with any LLM via Android Intent/sharing
  - No setup required—use apps you already have
  - Seamless copy/paste workflow
  - Optional: Configure local Ollama for fully automated generation

- **Content Organization**
  - Create learning decks by topic (Language, History, Math, etc.)
  - Tag-based organization system
  - Searchable content library
  - Bookmark favorite cards
  - Track content creation source

- **Metadata Capture**
  - Topic and learning goal
  - Generation date
  - Content difficulty level (can be specified in prompt)
  - User notes and customizations

**User Story**:
> As a Spanish learner, I want to ask my LLM to create 20 Spanish verb flashcards, paste them directly into Skill Forge, and immediately start practicing with interactive learning tools—all without any setup or configuration.

**Acceptance Criteria**:
- ✓ Generate prompts that guide users to LLM apps
- ✓ Support paste-back of plain text, formatted text, and markdown
- ✓ Auto-detect content format (vocabulary, definitions, Q&A)
- ✓ Quick validation showing items recognized before adding to deck
- ✓ One-tap sharing to installed LLM apps
- ✓ Seamless import from LLM response in under 3 seconds

---

### 2. **LLM-Powered Content Generation**

**Primary Goal**: Make it effortless for users to generate personalized learning material through their preferred LLM provider

#### A. Multi-Provider LLM Support
- **Android Intent Integration (Works with Any Installed LLM App)**
  - Detect installed LLM apps on device (ChatGPT, Gemini, Claude, etc.)
  - One-tap sharing to send prompts
  - User pastes response back into app
  - No auth required for web-based apps

- **Direct API Integration (For Power Users)**
  - Optional support for direct API connections
  - Supported providers: OpenAI, OpenRouter, Ollama, and LLM gateways (Portkey, etc.)
  - Users can configure preferred provider in settings
  - Fully optional—copy/paste workflow always available
  - API keys stored securely on device, never transmitted elsewhere

- **Guided Generation Workflow**
  - User specifies topic: *"Spanish Verbs"*
  - App generates ready-to-use prompt
  - Choose delivery method:
    - *Share* → pick installed app (ChatGPT, Gemini, etc.) → paste response back
    - *Auto-generate* → if direct API configured → receive content automatically
  - App recognizes format and imports automatically

- **Flexible Content Requests**
  - Language learning: vocabulary, grammar, dialogue examples
  - Academic: concept explanations, Q&A, case studies
  - Professional: skill building, code examples, best practices
  - Creative: writing prompts, brainstorming, storytelling
  - Customizable by topic, difficulty, and format

#### B. Optional Automation (For Configured Providers)
- **Full Automation Without Cloud Lock-In**
  - If user configures direct API (OpenAI, OpenRouter, Ollama, Portkey, etc.), generation can be fully automated
  - No need to manually copy/paste between apps
  - Still respects privacy—user controls data and provider
  - Seamless background processing with user's choice of provider

- **Provider Flexibility**
  - Users choose their preferred LLM provider
  - Easy switching between providers
  - Support for LLM gateways that route to multiple providers
  - No vendor lock-in

**User Story**:
> As a busy professional without local Ollama, I want to tap "Generate Spanish vocabulary" and share the prompt to ChatGPT, then paste the response back so I can practice—all without leaving the app or dealing with complex configuration. But if I prefer using OpenAI's API or an LLM gateway like Portkey, I can configure that for full automation.

**Acceptance Criteria**:
- ✓ Generate smart, structured prompts for any topic
- ✓ Detect and list installed LLM apps
- ✓ One-tap intent sharing to send prompts
- ✓ Automatic format detection when pasting results
- ✓ Works without any setup or configuration
- ✓ Optional: Direct API integration for OpenAI, OpenRouter, Ollama, Portkey, etc.
- ✓ Optional: Full automation for power users with configured providers

---

### 3. **Out-of-Box Learning Widgets**

**Primary Goal**: Provide multiple engaging ways to learn and practice

#### A. Flashcards
- **Features**:
  - Card flipping animation
  - Front/back content (question/answer, word/definition)
  - Navigation (previous, next, shuffle)
  - Performance marking (easy, medium, hard)
  - Swipe gestures for hands-free operation

- **Modes**:
  - *Study Mode*: Browse all cards, mark confidence
  - *Rapid Fire Mode*: Quick timed review (1-3 seconds per card)
  - *Random Mode*: Shuffle for variety
  - *Weak Points Mode*: Focus on previously marked "hard" cards

#### B. Spaced-Repetition Quiz
- **Features**:
  - Algorithm-based review scheduling
  - SM-2 or similar spaced-repetition algorithm
  - Adaptive difficulty (show harder items more frequently)
  - Automatic progression tracking
  - Due cards notification

- **Question Types**:
  - Multiple choice (auto-generated from deck)
  - True/false
  - Fill-in-the-blank
  - Matching pairs
  - Free text (with LLM grading when Ollama enabled)

#### C. Progressive Challenges
- **Features**:
  - Level-based progression (Bronze → Silver → Gold → Platinum)
  - Cumulative challenges combining multiple decks
  - Time-based challenges (learn N cards in 5 minutes)
  - Accuracy thresholds (85%+ to pass)
  - Streak tracking

#### D. Vocabulary Builder (Language Learning)
- **Features**:
  - Audio pronunciation (text-to-speech)
  - Visual context (example images for nouns)
  - Usage examples from corpus
  - Related words (synonyms, antonyms)
  - Practice sentences

**User Story**:
> As a language learner, I want multiple interactive ways to practice vocabulary so I stay engaged and learn through variety.

**Acceptance Criteria**:
- ✓ At least 4 learning widget types available
- ✓ Each widget has multiple modes/variations
- ✓ Smooth animations and transitions
- ✓ Clear progress feedback

---

### 4. **Gamification System**

**Primary Goal**: Make learning fun and encourage consistent practice

#### A. Achievement System
- **Badges** (with visual rewards)
  - *"First Steps"*: Complete first 5 cards
  - *"Quiz Master"*: Score 90%+ on quiz
  - *"Polyglot"*: Master 3 languages
  - *"Consistent Learner"*: 7-day streak
  - *"Power User"*: Generate 50+ LLM cards
  - *"Perfectionist"*: 100% quiz accuracy
  - *"Knowledge Seeker"*: 1000+ cards learned

#### B. Streak System
- **Daily Practice Streak**
  - Visual streak counter
  - Notification at end of day (optional)
  - Milestone rewards at 7, 30, 100 days
  - Streak recovery (one missed day forgiven per month)

#### C. Points & Levels
- **XP Earning**
  - Card practice: 10 XP per card
  - Quiz completion: 50-100 XP (based on score)
  - Challenge completion: 200+ XP
  - Bonus multiplier for consecutive days

- **Leveling System**
  - User level based on total XP
  - Level milestones unlock features or themes
  - Leaderboard (personal, friend, global - optional)

#### D. Challenges & Tournaments
- **Weekly Challenges**
  - "Learn 50 new words this week"
  - "Achieve 90%+ on all quizzes"
  - "Master one complete deck"
  - Rewards: bonus XP, badges, streak bonuses

- **Seasonal Tournaments** (Optional)
  - Monthly learning competitions
  - Leaderboard rankings
  - Exclusive badges/themes

**User Story**:
> As a gamification enthusiast, I want to earn badges, maintain streaks, and see my progress visually represented so I stay motivated to learn daily.

**Acceptance Criteria**:
- ✓ At least 5 distinct badge types
- ✓ Visible streak counter on home screen
- ✓ Clear XP/level progression
- ✓ Milestone celebrations (animations/notifications)

---

### 5. **Data Ownership & Portability**

**Primary Goal**: Users fully control their learning data with easy import/export

#### A. Export Functionality
- **Export Formats**:
  - *CSV*: Deck + cards, compatible with Anki, Quizlet
  - *JSON*: Full data including progress, settings, metadata
  - *PDF*: Printable deck study guide
  - *HTML*: Interactive study guide for web viewing

- **Export Scope Options**:
  - Single deck or all decks
  - Include/exclude progress data
  - Include/exclude metadata
  - Date range selection

- **Scheduled Backups** (Optional)
  - Automatic weekly/monthly local exports
  - Stored on device storage
  - One-tap restore from backup

#### B. Import Functionality
- **Supported Formats**:
  - Anki decks (.apkg, .anki)
  - Quizlet exports
  - CSV files
  - JSON backups
  - Custom formatted text
  - Content generated and shared from other sources

- **Merge Options**:
  - Create new deck
  - Merge with existing deck
  - Skip duplicates or overwrite
  - Preserve progress data

#### C. Data Integrity & Future P2P Sharing
- **No Cloud Lock-In**:
  - All data stored locally on device
  - No mandatory cloud sync or accounts
  - Clear data policy documentation
  - GDPR/privacy-compliant

- **Future: Optional P2P Sharing** (Not in MVP)
  - Share decks directly with friends
  - Peer-to-peer sync without cloud
  - Planned for future releases

**User Story**:
> As a privacy-conscious learner, I want to own my learning data and be able to export it anytime in standard formats so I'm not locked into any platform and can use my content elsewhere.

**Acceptance Criteria**:
- ✓ One-tap export to standard formats
- ✓ Successful import preserves all data
- ✓ No automatic cloud uploads or accounts required
- ✓ Clear privacy policy and data handling

---

### 6. **Accessibility & User Experience**

**Primary Goal**: Create an inclusive, high-performance learning experience

#### A. Text-to-Speech Integration
- **Features**:
  - Pronunciate card content with single tap
  - Auto-read on flashcards (optional)
  - Adjustable speech rate
  - Multiple language support
  - Works offline (native Android TTS)

- **Use Cases**:
  - Language learning pronunciation
  - Accessibility for visually impaired
  - Multitasking support (listen while driving)

#### B. Dark Theme
- **Implementation**:
  - OLED-optimized dark color palette
  - Automatic switch based on system settings
  - Manual override in settings
  - Dark theme for all screens and modals

- **Benefits**:
  - Reduced eye strain for evening study
  - Battery savings on OLED devices
  - Professional, modern appearance

#### C. High Performance
- **Optimization Goals**:
  - App launch < 1 second
  - Card transitions < 200ms
  - Quiz load < 500ms
  - Smooth 60 FPS animations
  - Low memory footprint (< 100MB with 1000 cards)

- **Strategies**:
  - Lazy loading for large decks
  - Image caching and compression
  - Efficient SQLite database
  - Hardware acceleration for animations

#### D. Intuitive UI/UX
- **Design Principles**:
  - Bottom navigation for main sections
  - Floating action button for quick actions
  - Card-based layout for content
  - Clear visual hierarchy
  - Consistent Material Design 3 patterns

- **Key Screens**:
  - *Home*: Overview, streaks, today's challenge
  - *Learn*: Deck browser and quick-start learning
  - *Progress*: Stats, achievements, charts
  - *Settings*: Preferences, data management, about

**User Story**:
> As a student, I want the app to be beautiful, fast, and easy to navigate so learning feels effortless and enjoyable.

**Acceptance Criteria**:
- ✓ App launches in < 1 second
- ✓ Smooth animations and transitions
- ✓ Dark theme available and optimized
- ✓ Text-to-speech works on all content
- ✓ Accessible to screen readers

---

### 7. **Offline-First, No Cloud Required**

**Primary Goal**: Work seamlessly offline without accounts or cloud services

#### A. Fully Offline Capable
- **All core features work offline**:
  - Practice flashcards
  - Complete quizzes
  - Track progress
  - Generate content (with local Ollama configured)
  - No internet required for learning
  - No accounts or logins needed

#### B. Future: Optional P2P Sharing (Post-MVP)
- **Planned Enhancement**:
  - Share decks directly with friends
  - No cloud intermediary
  - Fully peer-to-peer
  - User-controlled, optional feature

---

## 🏗️ Product Strategy

### How Skill Forge Works

**Skill Forge is an intelligent orchestrator for AI-powered learning material generation:**

1. **User specifies** what they want to learn (topic, subject, skill)
2. **App generates** a smart, structured prompt tailored to learning
3. **User chooses delivery method**:
   - *Share to app*: Tap to send prompt to ChatGPT, Gemini, or any installed LLM app → paste response back
   - *Auto-generate*: If provider API configured (OpenAI, OpenRouter, Ollama, Portkey, etc.) → content generated automatically
4. **LLM generates** structured learning content in the requested format
5. **App automatically** recognizes format and organizes content into learning decks
6. **User learns** using engaging flashcards, quizzes, and challenges

### LLM Flexibility & User Choice

This design provides **ultimate flexibility**:
- **No Setup Required**: Copy/paste workflow works immediately with any installed LLM app
- **Multiple Provider Options**: Users can configure their preferred provider (OpenAI, OpenRouter, Ollama, Portkey, etc.)
- **No Vendor Lock-In**: Switch between providers, use different providers for different topics
- **Privacy Respecting**: User controls data and LLM choice—everything stays on device
- **Automation Optional**: Set and forget with configured providers, or manually copy/paste for simplicity

### Content is Generated, Not Imported

Unlike apps that provide pre-built content libraries:
- Skill Forge empowers users to **generate their own personalized content**
- Every learning deck is tailored to the user's specific goals
- Content can be on any topic, at any difficulty level
- Generated content stays on the device—user owned, not licensed

---

---

## 🎓 Learning Content Model

### Content Types
1. **Flashcards**: Front/back pairs (word/definition, question/answer)
2. **Quizzes**: Multiple choice, true/false, fill-in-blank, matching
3. **Challenges**: Level-based progressive learning
4. **Study Sets**: Curated collections with learning goals

### Metadata Tracking
- Source and generation date
- Topic and learning goal
- Difficulty level
- User notes and customizations
- Review history and performance data

---

## 📊 Success Metrics & KPIs

### User Engagement
- **Daily Active Users (DAU)**: Target 80%+ of registered users
- **Daily Learning Time**: Average 15-30 minutes/day
- **Cards Learned**: Average 50+ cards/week per active user
- **Feature Adoption**: 70%+ using at least 3 learning widget types

### Learning Outcomes
- **Quiz Accuracy**: Average 80%+ on completed quizzes
- **Retention Rate**: 70%+ retention at 30-day follow-up
- **Streak Maintenance**: 60%+ users maintain 7+ day streaks
- **Content Completion**: 40%+ of imported decks completed

### Product Health
- **App Rating**: 4.5+ stars (Android Play Store target)
- **Crash Rate**: < 0.1%
- **Performance**: App launch < 1s, card transitions < 200ms
- **User Retention**: 50%+ 30-day retention rate

### LLM Integration
- **Provider Support**: 50%+ of DAU use LLM (ChatGPT, Gemini, OpenRouter, OpenAI, Ollama, or other providers)
- **Content Generation**: Users generate 50+ custom cards/week
- **Automation Adoption**: 30%+ of users configure optional provider API for automation

---

## 🚀 Implementation Roadmap

### Phase 1: MVP - Core Learning Experience (Months 1-2)
**Focus**: Build the learning engine and content generation workflow

- ✓ Content data models and organization
- ✓ Flashcard learning widget with multiple modes
- ✓ Basic quiz (multiple choice, true/false)
- ✓ Progress tracking & statistics dashboard
- ✓ Content generation prompt system
- ✓ Copy/paste workflow for LLM results
- ✓ Dark theme support
- ✓ Text-to-speech for all content
- ✓ Data export/import (CSV, JSON)

**Deliverable**: Fully functional learning app where users can generate, import, and practice content from any LLM via copy/paste

### 2. **LLM Integration & Automation (Months 2-3)**
**Focus**: Add direct API support and streamline the generation workflow

- ✓ Android Intent integration for discovered LLM apps
- ✓ One-tap prompt sharing to ChatGPT, Gemini, etc.
- ✓ Optional direct API configuration (OpenAI, OpenRouter, Ollama, Portkey, etc.)
- ✓ Automated content generation (if API configured)
- ✓ Provider management UI and settings

**Deliverable**: Users can generate content via copy/paste with any LLM app, or configure a provider API for full automation. Power users get flexible provider options.

### Phase 3: Gamification & Engagement (Months 3-4)
**Focus**: Make learning fun and habit-forming

- ✓ Achievement/badge system
- ✓ Daily streaks with notifications
- ✓ XP/leveling system
- ✓ Weekly challenges
- ✓ Leaderboard (personal stats focus, optional global)

**Deliverable**: Highly engaging, motivating learning experience with visible progress

### Phase 4: Advanced Learning Widgets (Months 4-5)
**Focus**: Multiple learning modalities for different styles

- ✓ Spaced-repetition quiz (SM-2 algorithm)
- ✓ Progressive challenges with levels
- ✓ Vocabulary builder with audio
- ✓ Matching games and quick drills
- ✓ Timed challenges

**Deliverable**: Users have diverse, proven learning methodologies in one app

### Phase 5: Data Portability & Advanced Features (Months 5-6)
**Focus**: Complete data ownership and extensibility

- ✓ Export to Anki, Quizlet formats
- ✓ PDF/HTML study guide export
- ✓ Backup and restore functionality
- ✓ Import from multiple sources
- ✓ Optional: Future P2P deck sharing foundation

**Deliverable**: Users fully own their data with multiple export options

### Phase 6: Polish & Launch (Months 6+)
**Focus**: Quality, performance, and distribution

- ✓ Performance optimization
- ✓ Accessibility audit and fixes
- ✓ Comprehensive testing
- ✓ Play Store submission
- ✓ Marketing & user acquisition
- ✓ Community feedback loops

**Deliverable**: Production-ready app on Google Play Store with strong user engagement

---

## 🔑 Key Differentiators

### 1. **Generation-First, Not Curation-First**
- Most apps provide pre-built content libraries
- Skill Forge generates personalized content on-demand
- Users control what they learn, how much detail, difficulty level
- Zero dependency on maintaining large content libraries

### 2. **Works with Any LLM**
- Not locked to specific services or providers
- Use ChatGPT today, switch to OpenRouter or local Ollama tomorrow
- Support for LLM gateways (Portkey, etc.) gives ultimate flexibility
- Zero cloud required—works with any provider user chooses

### 3. **Intelligent Content Orchestration**
- App guides users with smart prompt generation
- Detects and parses LLM output automatically
- Organizes content into optimal learning experiences
- No manual content formatting or cleanup needed

### 4. **True Data Ownership**
- No cloud lock-in, no accounts required
- Everything stays on device
- Easy export to standard formats (Anki, CSV, JSON)
- Users can take their data anywhere

### 5. **Privacy by Default**
- No tracking, no ads, no data collection
- Fully functional offline
- Optional P2P sharing in future (no cloud middleman)
- User data never leaves device without explicit action

---

### Persona 1: **The Language Learner**
- **Name**: Maria
- **Age**: 28
- **Goal**: Learn conversational Spanish in 6 months
- **Pain Points**: Bored with traditional apps, wants personalized content, needs mobile-first
- **Motivators**: Social sharing, visible progress, gamification
- **Frequency**: Daily, 20-30 minutes

### Persona 2: **The Busy Professional**
- **Name**: James
- **Age**: 35
- **Goal**: Learn programming fundamentals while commuting
- **Pain Points**: Limited time, needs offline access, wants quick sessions
- **Motivators**: Progress tracking, time efficiency, no ads
- **Frequency**: 3-4 times/week, 10-15 minutes

### Persona 3: **The Student**
- **Name**: Alex
- **Age**: 20
- **Goal**: Master exam material (history, biology, languages)
- **Pain Points**: Needs variety in learning formats, wants peer competition, needs structured plan
- **Motivators**: Achievements, rankings, community features
- **Frequency**: Variable, 30+ minutes before exams

### Persona 4: **The Privacy Advocate**
- **Name**: Sam
- **Age**: 32
- **Goal**: Learn new skills without data mining
- **Pain Points**: Distrusts cloud services, wants data ownership, values open source
- **Motivators**: Offline-first, export/import, no tracking
- **Frequency**: Daily, 15-20 minutes

---

## 🎯 Competitive Advantages

1. **Generation-First Approach**
   - Users generate exactly what they need, when they need it
   - No time wasted searching pre-built libraries
   - Infinite customization and topic variety

2. **LLM Flexibility**
   - Works with ChatGPT, Gemini, Claude via Android Intent
   - Optional direct API: OpenAI, OpenRouter, Ollama, Portkey, and other gateways
   - No vendor lock-in—users choose and switch providers anytime

3. **Zero Setup Required**
   - Works immediately with installed LLM apps
   - Copy/paste workflow is intuitive and fast
   - Optional API configuration for power users who want automation

4. **True Privacy**
   - No cloud required, no accounts needed
   - User data ownership guaranteed
   - Fully functional offline

5. **Smart Content Orchestration**
   - App handles complex prompt generation
   - Intelligent parsing of LLM output
   - Automatic organization and learning widget optimization

6. **Extensible Learning Experience**
   - Multiple learning widget types
   - Gamification to drive engagement
   - Easy to add new features and content formats

---

## 📋 Constraints & Assumptions

### Constraints
- **Android-only** initially (iOS later)
- **No subscription required** for core features
- **No cloud infrastructure needed** for MVP
- **Generated content only** (not pre-built libraries)
- **User provides LLM** (Ollama optional, external LLMs work too)

### Assumptions
- Users have access to at least one LLM (free web services or local Ollama)
- Users prefer generating personalized content over generic libraries
- Privacy-first approach appeals to target audience
- Learning motivation is primarily intrinsic

---

## 🔄 Feedback Loops & Iteration

### User Feedback Collection
- In-app feedback button
- Crash reports and error logging
- Usage analytics (privacy-respecting, on-device)
- User surveys (optional, in-app)

### Data-Driven Iteration
- Monthly progress review against KPIs
- Quarterly roadmap adjustments based on usage
- Continuous testing of new widgets/features
- A/B testing of UI/UX changes (within privacy constraints)

### Community Engagement
- GitHub discussions for feature requests
- Beta testing program for new features
- Transparent roadmap sharing
- Regular release notes and updates

---

## 📝 Definition of Done

Product is considered successfully launched when:

✓ MVP features complete and tested  
✓ App rating 4.0+ stars (100+ reviews)  
✓ 80%+ of DAU engage daily  
✓ <0.1% crash rate in production  
✓ Performance targets met (launch <1s, transitions <200ms)  
✓ Comprehensive user documentation  
✓ All accessibility requirements met  
✓ Ollama integration functional for 50%+ of users  
✓ Data export/import working reliably  
✓ 100% test coverage on critical paths  

---

## 🤝 Next Steps

1. **Product Refinement**
   - Validate with target users
   - Create detailed wireframes
   - Define interaction patterns

2. **Technical Spike**
   - Prototype core learning widgets
   - Test Ollama integration performance
   - Validate data model schema

3. **Team Alignment**
   - Review vision with development team
   - Assign ownership
   - Create detailed user stories (Phase 1)

4. **Launch Planning**
   - Set timeline for Phase 1 MVP
   - Define quality gates
   - Plan user testing strategy

---

## 📚 Appendices

### Related Documentation
- [OLLAMA_TOOLKIT_SUMMARY.md](OLLAMA_TOOLKIT_SUMMARY.md) - Available LLM integration foundation
- [AGENTS.md](../AGENTS.md) - AI agent roles for development
- [APP_CUSTOMIZATION.md](../APP_CUSTOMIZATION.md) - Customization guide

### Reference Materials
- Flutter Learning: https://docs.flutter.dev
- Material Design 3: https://m3.material.io
- Ollama Documentation: https://ollama.ai (optional for advanced users)
- Anki File Format: https://github.com/ankitects/anki (for export compatibility)

### Tools & Resources
- GitHub Copilot for development assistance
- VS Code for development and testing
- Android Studio for device debugging

---

**Document Control**:
- **Last Updated**: January 6, 2026
- **Next Review**: April 6, 2026
- **Owner**: Product Team
- **Status**: Active - Ready for development
