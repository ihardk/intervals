# Interval App - Technical Architecture

## Overview

Interval is a cross-platform mobile application built with React Native and TypeScript, designed for iOS and Android. The architecture emphasizes minimalism, performance, and privacy.

## Technology Stack

### Core Framework
- **React Native 0.73+** - Cross-platform mobile framework
- **TypeScript 5.0+** - Type-safe development
- **Expo** - Development tooling and managed workflow (optional for rapid MVP)

### State Management
- **Zustand** - Lightweight state management
- **React Query** - Async state and caching

### Local Storage
- **SQLite** (via `react-native-sqlite-storage` or `expo-sqlite`)
- **AsyncStorage** - Settings and preferences
- **MMKV** - High-performance key-value storage for cache

### Background Processing
- **React Native Background Fetch** - Background task scheduling
- **React Native Push Notification** - Local notification system
- **Notifee** - Advanced notification handling (Android)

### Voice & Audio
- **React Native Voice** - Speech-to-text transcription
- **Expo AV** - Audio recording and playback
- **On-device ML Kit** (Android) / Speech Framework (iOS)

### UI Components
- **React Native Core Components** - Base UI
- **React Native Reanimated** - Smooth animations
- **React Native Gesture Handler** - Touch interactions

### Data Visualization
- **Victory Native** - Charts and graphs
- **React Native SVG** - Custom visualizations

### Security
- **expo-crypto** - Encryption at rest
- **react-native-keychain** - Secure credential storage

### Testing
- **Jest** - Unit testing
- **React Native Testing Library** - Component testing
- **Detox** - E2E testing

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Logging │  │ Insights │  │ History  │  │Settings │ │
│  │  Screen  │  │  Screen  │  │  Screen  │  │ Screen  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Business Logic Layer                  │
│  ┌────────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │ Log Service│  │ Insight  │  │ Notification       │  │
│  │            │  │ Generator│  │ Scheduler Service  │  │
│  └────────────┘  └──────────┘  └────────────────────┘  │
│  ┌────────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │ Voice      │  │ Pattern  │  │ Export Service     │  │
│  │ Transcribe │  │ Detector │  │                    │  │
│  └────────────┘  └──────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Access Layer                     │
│  ┌────────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │ Repository │  │ Settings │  │ Cache Manager      │  │
│  │ Pattern    │  │ Store    │  │                    │  │
│  └────────────┘  └──────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Persistence Layer                     │
│  ┌────────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │  SQLite    │  │AsyncStore│  │   MMKV Cache       │  │
│  │  Database  │  │          │  │                    │  │
│  └────────────┘  └──────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Background Services Architecture

```
┌────────────────────────────────────────────────┐
│         Notification Scheduler Service          │
│  ┌──────────────────────────────────────────┐  │
│  │   Interval Timer (15/30 min)             │  │
│  │   - Background Fetch                     │  │
│  │   - Alarm Manager (Android)              │  │
│  │   - Background App Refresh (iOS)         │  │
│  └──────────────────────────────────────────┘  │
│                     ▼                           │
│  ┌──────────────────────────────────────────┐  │
│  │   Local Notification Trigger             │  │
│  │   - Quick Actions: Text/Voice/Skip       │  │
│  │   - Custom notification layout           │  │
│  └──────────────────────────────────────────┘  │
│                     ▼                           │
│  ┌──────────────────────────────────────────┐  │
│  │   User Response Handler                  │  │
│  │   - Log entry creation                   │  │
│  │   - Next interval scheduling             │  │
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

## Application Flow

### App Launch Flow
1. Initialize SQLite database
2. Load user settings (interval preference)
3. Check notification permissions
4. Restore background scheduler state
5. Navigate to main logging screen

### Notification Flow
1. Background scheduler triggers at interval
2. Local notification sent with quick actions
3. User taps action:
   - **Text Log**: Open app to text input
   - **Voice Log**: Open app to voice recorder
   - **Skip**: Dismiss and schedule next
4. Log saved to database
5. Next interval scheduled

### Logging Flow
1. User opens app or responds to notification
2. Logging screen appears (auto-focused text input)
3. User enters text OR records voice
4. Voice transcribed (on-device)
5. Log entry saved with timestamp
6. Optional: Show brief success feedback
7. Return to home or close

### Insights Generation Flow
1. User navigates to Insights tab
2. Query logs for current day/week/month
3. Calculate statistics:
   - Total logs
   - Skipped intervals
   - Streak count
4. Pattern detection algorithm runs:
   - Keyword frequency analysis
   - Time-based clustering
   - Category detection
5. Render visualizations and summaries

## Module Structure

```
src/
├── components/          # Reusable UI components
│   ├── common/         # Buttons, inputs, cards
│   ├── logging/        # Text/voice input components
│   ├── insights/       # Charts, stats displays
│   └── history/        # Log list, calendar
├── screens/            # Main app screens
│   ├── Onboarding/
│   ├── Logging/
│   ├── Insights/
│   ├── History/
│   └── Settings/
├── services/           # Business logic
│   ├── database/       # SQLite operations
│   ├── notification/   # Notification scheduling
│   ├── voice/          # Speech-to-text
│   ├── insights/       # Pattern detection
│   └── export/         # Data export
├── store/              # State management
│   ├── logsStore.ts
│   ├── settingsStore.ts
│   └── insightsStore.ts
├── models/             # TypeScript types
│   ├── Log.ts
│   ├── Settings.ts
│   └── Insight.ts
├── utils/              # Helper functions
│   ├── dateHelpers.ts
│   ├── validation.ts
│   └── encryption.ts
├── constants/          # App constants
│   ├── colors.ts
│   ├── intervals.ts
│   └── notifications.ts
├── navigation/         # Navigation setup
│   └── AppNavigator.tsx
└── App.tsx            # Root component
```

## Data Flow Patterns

### Unidirectional Data Flow
- User actions → Services → Database → State updates → UI re-render
- No direct database access from components
- Repository pattern for data access abstraction

### State Management Strategy
- **Local component state**: UI-only state (input values, animations)
- **Zustand global store**: App-wide state (current log, settings)
- **React Query cache**: Server/database queries with auto-refresh
- **AsyncStorage**: Persisted settings and preferences

## Performance Optimization

### Database Optimization
- Indexed columns: `timestamp`, `created_at`
- Batch inserts for bulk operations
- Connection pooling
- Query result pagination

### UI Performance
- React.memo for expensive components
- useMemo/useCallback for heavy computations
- FlatList with windowing for long lists
- Image lazy loading
- Animation on native thread (Reanimated)

### Background Efficiency
- Minimal background task duration
- Batch database writes
- Wake locks only when necessary
- Battery-optimized scheduling

## Security & Privacy

### Data Protection
- All logs encrypted at rest (AES-256)
- No analytics or tracking by default
- Optional cloud sync with end-to-end encryption
- Secure storage for encryption keys (Keychain/KeyStore)

### Privacy Principles
- Data never leaves device unless explicitly enabled
- No third-party SDKs with data collection
- Voice transcription on-device only
- Export data in user-controlled formats

## Platform-Specific Considerations

### iOS
- Background App Refresh for notification scheduling
- Speech Framework for voice transcription
- HealthKit integration potential (future)
- StoreKit for potential premium features

### Android
- Foreground Service for reliable notifications
- WorkManager for background tasks
- ML Kit for voice transcription
- Battery optimization exemptions handling

## Scalability Considerations

### Database Growth
- Archive logs older than 1 year
- Incremental backup strategy
- Database vacuum on schedule
- Export before archive

### Feature Expansion
- Plugin architecture for AI module
- Modular insight generators
- Extensible export formats
- API-ready architecture for future sync service

## Error Handling

### Notification Failures
- Retry with exponential backoff
- Fallback to manual logging prompt
- User notification of permission issues

### Voice Transcription Failures
- Graceful fallback to audio-only storage
- Retry mechanism
- Manual transcription edit option

### Database Errors
- Transaction rollback
- Automatic backup restoration
- User-friendly error messages
- Crash reporting (privacy-respecting)

## Testing Strategy

### Unit Tests
- Service layer functions
- Utility functions
- Data transformations
- Pattern detection algorithms

### Integration Tests
- Database operations
- Notification scheduling
- State management flows

### E2E Tests
- Complete user journeys
- Onboarding flow
- Logging flow
- Insights generation

## Deployment Architecture

### Development
- Expo Go for rapid iteration
- Hot reload enabled
- Debug builds with dev menu

### Staging
- TestFlight (iOS) / Internal Testing (Android)
- Beta tester feedback loop
- Performance monitoring

### Production
- App Store / Google Play
- OTA updates for JS bundles (Expo)
- Crash reporting
- Analytics (privacy-focused)

## Future Architecture Considerations

### Cloud Sync (Phase 4)
- REST API with JWT authentication
- Conflict resolution strategy
- Incremental sync
- End-to-end encryption

### AI Module (Phase 3)
- On-device ML model (CoreML/TensorFlow Lite)
- Privacy-preserving insights
- Optional cloud-based LLM integration
- User consent required

### Multi-Device Support
- Device registration
- Sync conflict resolution
- Offline-first with eventual consistency

## Monitoring & Analytics

### Performance Metrics
- App launch time
- Screen render time
- Database query performance
- Notification delivery rate

### User Metrics (Privacy-Respecting)
- Logs per day (anonymized)
- Feature usage (local only)
- Crash rate
- Retention rates

### Health Checks
- Database integrity checks
- Background service status
- Storage usage monitoring
- Battery impact tracking
