# Interval - Minimalist Awareness & Productivity Logger

A minimalist mobile app designed to increase productivity through intentional awareness of how you spend your time.

## 📱 Overview

Interval prompts you every 15 or 30 minutes to log what you're doing via quick text or voice input. It helps you build awareness habits that naturally improve productivity through:

- **Minimalism**: Clean, distraction-free interface in black, white, and grey
- **Mindfulness**: Increase self-awareness through frequent micro-reflection
- **Productivity**: Build consistency and reveal behavioral patterns

## 🏗️ Project Status

**Current Phase**: Phase 1 MVP Core - Feature Complete! 🎉

### ✅ Completed (Phase 1)

**Foundation:**
- ✅ Technical architecture documentation
- ✅ Database schema design & API specifications
- ✅ React Native project structure with TypeScript
- ✅ Core data models (Log, Interval, Settings, Insight, Category)
- ✅ Database service with SQLite integration and migrations

**Services:**
- ✅ LogService - Complete CRUD operations
- ✅ SettingsService - Persistent preferences management
- ✅ CategoryService - Auto-categorization with keyword matching
- ✅ IntervalService - Interval tracking and completion rates
- ✅ NotificationService - Local notifications with @notifee

**State Management:**
- ✅ Zustand stores (logs, settings, insights)
- ✅ Async state handling with error management

**Navigation:**
- ✅ React Navigation setup (Stack + Bottom Tabs)
- ✅ Deep linking support for notifications
- ✅ Conditional routing based on onboarding status

**UI Components:**
- ✅ Button (primary, secondary, ghost variants)
- ✅ TextInput with validation and character counter
- ✅ Card component
- ✅ LoadingSpinner

**Screens - Onboarding Flow:**
- ✅ Welcome Screen - Brand introduction
- ✅ Interval Selection Screen - Choose 15 or 30 minutes
- ✅ Permissions Screen - Request notification access

**Screens - Main App:**
- ✅ Logging Screen - Text input with auto-focus, recent logs preview
- ✅ History Screen - Chronological log list with pull-to-refresh
- ✅ Insights Screen - Basic stats and top activities visualization
- ✅ Settings Screen - Interval duration, toggles for features

**Features:**
- ✅ Text-based activity logging
- ✅ Auto-categorization based on keywords
- ✅ Today's logs view with timestamps
- ✅ Basic daily insights (total logs, categories, stats)
- ✅ Settings persistence
- ✅ Minimalist black/white/grey design implemented

### 🚧 Next Up (Phase 2)
- Voice recording and transcription
- Advanced insights with pattern detection
- Charts and visualizations
- Export functionality

See [ROADMAP.md](./ROADMAP.md) and [TASK_BREAKDOWN.md](./TASK_BREAKDOWN.md) for detailed plans.

## 📚 Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and technical design
- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Database schema and queries
- **[API_SPECIFICATIONS.md](./API_SPECIFICATIONS.md)** - Service interfaces and types
- **[ROADMAP.md](./ROADMAP.md)** - Development roadmap and milestones

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- React Native development environment
  - For iOS: Xcode, CocoaPods
  - For Android: Android Studio, Java Development Kit
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd intervals
```

2. Install dependencies:
```bash
npm install
```

3. iOS specific setup:
```bash
cd ios && pod install && cd ..
```

4. Start the development server:
```bash
npm start
```

5. Run on iOS:
```bash
npm run ios
```

6. Run on Android:
```bash
npm run android
```

## 🛠️ Tech Stack

- **Framework**: React Native 0.73+
- **Language**: TypeScript 5.0+
- **State Management**: Zustand
- **Database**: SQLite (react-native-sqlite-storage)
- **Notifications**: Notifee
- **Voice**: @react-native-voice/voice
- **Navigation**: React Navigation
- **Storage**: MMKV for caching

## 📦 Project Structure

```
intervals/
├── src/
│   ├── components/      # Reusable UI components
│   ├── screens/         # Main app screens
│   ├── services/        # Business logic layer
│   │   ├── database/    # SQLite operations
│   │   ├── logs/        # Log management
│   │   ├── settings/    # Settings management
│   │   └── categories/  # Category operations
│   ├── store/           # Zustand state management
│   ├── models/          # TypeScript types and interfaces
│   ├── utils/           # Helper functions
│   ├── constants/       # App constants
│   └── navigation/      # Navigation configuration
├── App.tsx              # Root component
├── index.js             # App entry point
└── package.json         # Dependencies
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run type checking
npm run typecheck

# Run linter
npm run lint
```

## 🎨 Design Philosophy

### Minimalism
- Black (#000000), White (#FFFFFF), Grey spectrum
- Sans-serif typography
- High contrast
- Whitespace > 50%

### Interaction Principles
- Maximum 2 taps for core actions
- Auto-focus on inputs
- Fast transitions (<700ms)
- Haptic feedback for confirmations

### Privacy First
- Data encrypted at rest
- No external tracking
- On-device voice transcription
- Local-first storage

## 📊 Core Features (Planned)

### Phase 1 - MVP (Weeks 1-3)
- ✅ Database and infrastructure
- 🚧 Text logging
- 🚧 Notification system
- ⏳ Basic history view

### Phase 2 - Enhanced (Weeks 4-6)
- ⏳ Voice input and transcription
- ⏳ Daily insights and analytics
- ⏳ Auto-categorization
- ⏳ Pattern detection

### Phase 3 - Polish (Weeks 7-8)
- ⏳ Settings and preferences
- ⏳ Data export (CSV/JSON)
- ⏳ Performance optimization
- ⏳ Comprehensive testing

### Phase 4 - Release (Weeks 9-10)
- ⏳ App store preparation
- ⏳ Beta testing
- ⏳ Launch

## 🤝 Contributing

This is currently in active development. Contributions will be welcome after the MVP release.

## 📄 License

[To be determined]

## 🔗 Links

- Product Requirements: See PRD in project docs
- Technical Design: See ARCHITECTURE.md
- Development Roadmap: See ROADMAP.md

## ⚡ Development Commands

```bash
# Start Metro bundler
npm start

# Run on iOS
npm run ios

# Run on Android
npm run android

# Run tests
npm test

# Type check
npm run typecheck

# Lint
npm run lint

# Install iOS pods
npm run pod-install
```

## 📞 Support

For questions or issues, please open a GitHub issue.

---

**Version**: 1.0.0-alpha
**Last Updated**: 2025-12-12
