# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Interval** is a minimalist React Native mobile app for iOS and Android that helps users build awareness and productivity through intentional time tracking. Users receive notifications every 15 or 30 minutes to log what they're doing via text or voice input.

**Tech Stack:**
- React Native 0.83 with TypeScript 5.8
- State Management: Zustand
- Database: SQLite (react-native-sqlite-storage)
- Notifications: Notifee
- Navigation: React Navigation (Stack + Bottom Tabs)
- Voice: @react-native-voice/voice

## Development Commands

### Running the App
```bash
npm start                    # Start Metro bundler
npm run ios                  # Run on iOS simulator
npm run android              # Run on Android emulator
npm run pod-install          # Install iOS CocoaPods dependencies (cd ios && pod install)
```

### Testing & Quality
```bash
npm test                     # Run Jest tests
npm run typecheck            # Run TypeScript compiler checks (tsc --noEmit)
npm run lint                 # Run ESLint
```

### Running Individual Tests
```bash
npm test -- HapticService    # Run tests matching "HapticService"
npm test -- --watch          # Run tests in watch mode
npm test -- --coverage       # Run tests with coverage report
```

## Architecture Overview

### Layered Architecture

The app follows a strict layered architecture pattern:

1. **Presentation Layer** (`src/screens/`, `src/components/`)
   - Screens and UI components
   - No direct database access
   - Interact with services via Zustand stores

2. **Business Logic Layer** (`src/services/`)
   - Service modules contain all business logic
   - Each service is a singleton instance exported from its file
   - Services include: LogService, SettingsService, CategoryService, IntervalService, NotificationService, VoiceService, InsightService, ExportService, StreakService, HapticService

3. **Data Access Layer** (`src/services/database/`)
   - DatabaseService wraps SQLite operations
   - Handles migrations and transactions
   - Repository pattern for data access abstraction

4. **State Management** (`src/store/`)
   - Zustand stores: logsStore, settingsStore, insightsStore
   - Stores call services, services update database
   - Unidirectional data flow: UI → Store → Service → Database → Store → UI

### Key Architectural Patterns

**Service Layer Pattern:**
- All services are singletons exported as instances (e.g., `export const logService = new LogService()`)
- Services expose async methods that return Promises
- Services handle error boundaries and logging
- No component should directly import DatabaseService - always go through domain services

**Database Migrations:**
- DatabaseService.ts manages versioned schema migrations
- Migrations are run automatically on app initialization
- Current schema version tracked in `migrations` table
- See DATABASE_SCHEMA.md for complete schema design

**Notification Flow:**
- NotificationService schedules interval notifications via Notifee
- Notifications include quick actions (Text/Voice/Skip)
- Deep linking handled by NavigationService
- IntervalService tracks completion rates and user engagement

**Auto-categorization:**
- CategoryService uses keyword matching algorithm
- Default categories: Work, Break, Learning, Social, Distraction
- Categories stored in database with JSON keyword arrays
- Logs are auto-categorized on creation if settings.autoCategorize is true

### Navigation Structure

```
AppNavigator (Stack)
├── Onboarding Flow
│   ├── Welcome
│   ├── IntervalSelection (15 or 30 minutes)
│   └── Permissions (notification access)
└── MainTabs (Bottom Tabs)
    ├── Logging (Home)
    ├── History
    ├── Insights
    └── Settings
```

**Conditional Routing:** App checks `settings.onboardingCompleted` on launch to determine initial route.

**Deep Linking:** NavigationService handles notification tap actions, routing to LoggingScreen with preselected mode (text/voice).

## Project Structure

```
src/
├── components/
│   ├── common/          # Reusable UI: Button, TextInput, Card, LoadingSpinner, Toast, etc.
│   ├── calendar/        # CalendarView for history
│   ├── insights/        # InsightsCharts (Victory Native)
│   ├── modals/          # EditLogModal
│   └── voice/           # VoiceRecorder component
├── screens/
│   ├── Onboarding/      # WelcomeScreen, IntervalSelectionScreen, PermissionsScreen
│   ├── Logging/         # LoggingScreen (main home screen with text/voice input)
│   ├── History/         # HistoryScreen (chronological log list)
│   ├── Insights/        # InsightsScreen (stats, charts, patterns)
│   └── Settings/        # SettingsScreen (preferences)
├── services/
│   ├── database/        # DatabaseService (SQLite wrapper, migrations)
│   ├── logs/            # LogService (CRUD for logs)
│   ├── settings/        # SettingsService (app preferences)
│   ├── categories/      # CategoryService (auto-categorization)
│   ├── intervals/       # IntervalService (interval tracking)
│   ├── notification/    # NotificationService, NotificationScheduler
│   ├── voice/           # VoiceService (speech-to-text)
│   ├── insights/        # InsightService (analytics, pattern detection)
│   ├── export/          # ExportService (CSV/JSON export)
│   ├── streaks/         # StreakService (consistency tracking)
│   └── haptics/         # HapticService (haptic feedback)
├── store/
│   ├── logsStore.ts     # Zustand store for logs state
│   ├── settingsStore.ts # Zustand store for app settings
│   └── insightsStore.ts # Zustand store for insights data
├── models/              # TypeScript interfaces: Log, Interval, Settings, Insight, Category
├── constants/           # colors.ts, intervals.ts, notifications.ts
├── navigation/          # AppNavigator, NavigationService, types.ts
└── utils/               # Helper functions
```

## Database Schema

**Primary Tables:**
- `logs` - User activity entries (id, timestamp, content, entry_type, category, tags, etc.)
- `intervals` - Notification intervals and user responses
- `settings` - Key-value settings storage
- `insights` - Pre-computed analytics (cached)
- `categories` - Category definitions with keywords
- `streaks` - User consistency tracking
- `exports` - Export history

**Key Indexes:**
- `idx_logs_timestamp` on logs(timestamp DESC) - optimizes today's logs queries
- `idx_logs_category` on logs(category) - speeds up category filtering
- `idx_intervals_scheduled` on intervals(scheduled_time DESC)

See DATABASE_SCHEMA.md for complete schema documentation.

## TypeScript Path Aliases

The project uses path aliases defined in tsconfig.json:

```typescript
"@/*": ["src/*"]
"@components/*": ["src/components/*"]
"@screens/*": ["src/screens/*"]
"@services/*": ["src/services/*"]
"@models/*": ["src/models/*"]
"@store/*": ["src/store/*"]
"@utils/*": ["src/utils/*"]
"@constants/*": ["src/constants/*"]
```

**Note:** These aliases work for TypeScript type checking but may require Metro bundler configuration for runtime resolution. When in doubt, use relative imports.

## Data Models

All TypeScript interfaces are defined in `src/models/`:

**Log Model:**
```typescript
interface Log {
  id: string;                    // UUID v4
  timestamp: number;              // Unix ms (when activity happened)
  content: string;                // Log text
  entryType: 'text' | 'voice' | 'manual';
  category?: string;
  tags?: string[];
  isDeleted: boolean;             // Soft delete
  // ... see models/Log.ts for complete definition
}
```

**All timestamps are Unix epoch in milliseconds.**
**All dates stored as ISO 8601 strings (YYYY-MM-DD).**

## State Management Pattern

**Zustand Store Flow:**
1. Component calls store action (e.g., `logsStore.createLog()`)
2. Store action calls service method (e.g., `logService.createLog()`)
3. Service updates database and returns result
4. Store updates its state with the result
5. Component re-renders with new state

**Example:**
```typescript
// In component
const createLog = useLogsStore((state) => state.createLog);
await createLog({ content: 'Working on code', entryType: 'text' });

// In logsStore.ts
createLog: async (input) => {
  set({ isLoading: true });
  try {
    const log = await logService.createLog(input);
    set((state) => ({ logs: [log, ...state.logs] }));
    return log;
  } catch (error) {
    set({ error: error.message });
  } finally {
    set({ isLoading: false });
  }
}
```

## Design System

**Colors:** Black (#000000), White (#FFFFFF), Grey spectrum
- Defined in `src/constants/colors.ts`
- Minimalist, high-contrast design
- No color beyond black/white/grey (except category colors in insights)

**Typography:** Sans-serif, multiple font sizes defined in Colors.typography

**Interaction Principles:**
- Auto-focus on text inputs
- Haptic feedback via HapticService for button presses and confirmations
- Fast transitions (<700ms)
- Maximum 2 taps for core actions

## Common Development Patterns

### Creating a New Service

1. Define interface in `src/services/[domain]/[Name]Service.ts`
2. Implement class with async methods
3. Export singleton instance: `export const myService = new MyService()`
4. Add database queries if needed via `databaseService.executeSql()`
5. Write Jest tests in `__tests__/[Name]Service.test.ts`

### Adding a New Screen

1. Create component in `src/screens/[Section]/[Name]Screen.tsx`
2. Add route to `src/navigation/AppNavigator.tsx`
3. Add type to `src/navigation/types.ts` for type-safe navigation
4. Use Zustand stores for state, not local useState for data
5. Follow SafeAreaView pattern from existing screens

### Database Queries

Always use parameterized queries to prevent SQL injection:

```typescript
// GOOD
await databaseService.executeSql(
  'SELECT * FROM logs WHERE category = ? AND timestamp > ?',
  [category, startTime]
);

// BAD - SQL injection risk
await databaseService.executeSql(
  `SELECT * FROM logs WHERE category = '${category}'`
);
```

### Haptic Feedback

Use HapticService for tactile feedback:

```typescript
import { hapticService } from '@services/haptics/HapticService';

// On button press
hapticService.selection();

// On success
hapticService.success();

// On error
hapticService.error();
```

## Testing

**Test Configuration:** Jest with ts-jest preset (see jest.config.js)

**Coverage Requirements:**
- Statements: 70%
- Branches: 60%
- Functions: 70%
- Lines: 70%

**Test Location:** `src/services/**/__tests__/*.test.ts`

**Mocking:** Tests use mocks for SQLite and React Native modules (see jest.setup.js)

**Example Test Structure:**
```typescript
describe('ServiceName', () => {
  beforeEach(() => {
    // Setup
  });

  it('should do something', async () => {
    // Test implementation
  });
});
```

## Important Files to Reference

- **ARCHITECTURE.md** - Detailed technical architecture, background services, security
- **DATABASE_SCHEMA.md** - Complete schema, indexes, common queries, performance considerations
- **API_SPECIFICATIONS.md** - Service interfaces, type definitions, event handlers
- **README.md** - Project overview, setup instructions, roadmap
- **package.json** - Dependencies and scripts

## Settings Persistence

Settings are stored in SQLite `settings` table and loaded on app start via SettingsService. Key settings:

- `intervalDuration`: 900000 (15min) or 1800000 (30min)
- `notificationsEnabled`: boolean
- `onboardingCompleted`: boolean (determines initial route)
- `autoCategorize`: boolean (enables/disables auto-categorization)

**Settings are loaded in App.tsx during initialization and managed via settingsStore.**

## Notification System

The app uses **Notifee** for local notifications (not push notifications from a server). NotificationService handles:

- Scheduling interval-based notifications
- Quick action buttons on notifications (Text/Voice/Skip)
- Permission requests
- Deep linking to LoggingScreen

**Background Processing:**
- iOS: Background App Refresh
- Android: Foreground Service for reliable delivery

See ARCHITECTURE.md section "Background Services Architecture" for details.

## Voice Transcription

VoiceService wraps @react-native-voice/voice for speech-to-text:

- On-device transcription (privacy-focused)
- Returns TranscriptionResult with text and confidence
- Audio files stored locally with path in logs.audio_path
- TranscriptionStatus tracked: 'pending' | 'complete' | 'failed'

## Privacy & Security

- **Local-first:** All data stored on-device in SQLite
- **Encryption:** Database can be encrypted at rest (future: AES-256 with key in Keychain)
- **No external tracking:** No analytics SDKs, no telemetry without consent
- **On-device ML:** Voice transcription happens locally

## Known Issues & Considerations

1. **SafeAreaView Configuration:** Recent commits fixed SafeAreaView issues - use `edges={['top', 'bottom']}` prop and wrap with `<SafeAreaProvider>` in App.tsx

2. **Settings Persistence:** Recent fix ensures settings are properly saved during onboarding flow - always use `settingsService.setSetting()` or store actions

3. **Haptic Feedback:** HapticService is tested and working - use for all button interactions

4. **TypeScript Strict Mode:** tsconfig has `strict: true` - all code must satisfy strict type checking

5. **Metro Bundler:** Path aliases may not work at runtime - prefer relative imports if encountering module resolution issues

## Git Workflow

**Current Branch:** `claude/interval-awareness-logger-01JVmF6ve87T6RDuDaG3kwAo`

**Recent Work:**
- Fixed settings persistence during onboarding
- Added Jest testing infrastructure with HapticService tests
- Fixed SafeAreaView issues throughout the app

## Version

**App Version:** 1.0.0-alpha
**Last Updated:** 2025-12-12
