# Flutter Migration: Phase-by-Phase Todo List

**Current Status:** ✅ Phase 1 Complete | 📍 Starting Phase 2

---

## ✅ PHASE 1: Core Infrastructure & Database (COMPLETE)

### Project Setup ✅
- [x] Create Flutter project with proper folder structure
- [x] Add all dependencies to pubspec.yaml
- [x] Setup BDD testing environment

### Database Layer ✅
- [x] Create app_database.dart with Drift configuration
- [x] Define all 7 table schemas (logs, intervals, settings, insights, categories, streaks, exports)
- [x] Generate Drift code with build_runner
- [x] Implement all 7 DAOs (data access objects)
- [x] Write comprehensive DAO tests (86 tests - BDD style)
- [x] Verify all DAO tests passing

### Core Infrastructure ✅
- [x] Create core constants (colors, text_styles, intervals, app_constants)
- [x] Define AppTheme with minimalist black/white/grey design
- [x] Create error handling (failures.dart, exceptions.dart)
- [x] Setup date helpers utility

### Domain Entities ✅
- [x] Define Log entity (freezed)
- [x] Define Interval entity (freezed)
- [x] Define Settings entity (freezed)
- [x] Define Insight entity (freezed)
- [x] Define Category entity (freezed)
- [x] Define Streak entity (freezed)

**Total Progress: 100% ✅**

---

## 📍 PHASE 2: Repository Layer (Domain Interfaces)

**Goal:** Create repository interfaces (contracts) in domain layer

### Logging Feature
- [ ] Create `lib/features/logging/domain/repositories/log_repository.dart`
  - Methods: createLog, getTodayLogs, getLogById, updateLog, deleteLog, searchLogs
- [ ] Create `lib/features/logging/domain/repositories/interval_repository.dart`
  - Methods: createInterval, completeInterval, getTodayIntervals, getCompletionRate

### Settings Feature
- [ ] Create `lib/features/settings/domain/repositories/settings_repository.dart`
  - Methods: getSetting, setSetting, updateSettings, getAllSettings

### Categories Feature
- [ ] Create `lib/features/categories/domain/repositories/category_repository.dart`
  - Methods: categorizeContent, getCategories, addCategory, updateCategory, deleteCategory

### Insights Feature
- [ ] Create `lib/features/insights/domain/repositories/insight_repository.dart`
  - Methods: generateDailyInsight, getTodayInsight, getTopActivities, calculateCompletionRate

### Streaks Feature
- [ ] Create `lib/features/streaks/domain/repositories/streak_repository.dart`
  - Methods: getCurrentStreak, incrementStreak, breakStreak, getActiveStreaks

### Export Feature
- [ ] Create `lib/features/export/domain/repositories/export_repository.dart`
  - Methods: exportToCSV, exportToJSON, getExportHistory, deleteOldExports

**Estimated Time:** 2-3 hours
**Total Progress: 0/7 repositories**

---

## 📍 PHASE 3: Repository Tests & Implementation (Data Layer)

**Goal:** Write tests first (BDD), then implement repositories

### 3A. Repository Tests (Test-First!)
- [ ] `test/features/logging/data/repositories/log_repository_impl_test.dart` (BDD tests)
- [ ] `test/features/logging/data/repositories/interval_repository_impl_test.dart`
- [ ] `test/features/settings/data/repositories/settings_repository_impl_test.dart`
- [ ] `test/features/categories/data/repositories/category_repository_impl_test.dart`
- [ ] `test/features/insights/data/repositories/insight_repository_impl_test.dart`
- [ ] `test/features/streaks/data/repositories/streak_repository_impl_test.dart`
- [ ] `test/features/export/data/repositories/export_repository_impl_test.dart`

### 3B. Repository Implementations
- [ ] `lib/features/logging/data/repositories/log_repository_impl.dart`
  - Include auto-categorization logic
  - Convert between Drift data models and domain entities
- [ ] `lib/features/logging/data/repositories/interval_repository_impl.dart`
- [ ] `lib/features/settings/data/repositories/settings_repository_impl.dart`
- [ ] `lib/features/categories/data/repositories/category_repository_impl.dart`
  - Implement keyword-based categorization algorithm
- [ ] `lib/features/insights/data/repositories/insight_repository_impl.dart`
  - Implement analytics calculations
- [ ] `lib/features/streaks/data/repositories/streak_repository_impl.dart`
- [ ] `lib/features/export/data/repositories/export_repository_impl.dart`

### 3C. Verify Tests Pass
- [ ] Run all repository tests
- [ ] Ensure 100% test coverage for repository business logic

**Estimated Time:** 1-2 days
**Total Progress: 0/7 repositories tested + implemented**

---

## PHASE 4: Use Cases (Domain Layer)

**Goal:** Create focused use cases following Single Responsibility Principle

### Logging Use Cases
- [ ] `CreateLog` use case + tests
- [ ] `GetTodayLogs` use case + tests
- [ ] `GetLogById` use case + tests
- [ ] `UpdateLog` use case + tests
- [ ] `DeleteLog` use case + tests
- [ ] `SearchLogs` use case + tests

### Interval Use Cases
- [ ] `CreateInterval` use case + tests
- [ ] `CompleteInterval` use case + tests
- [ ] `GetTodayCompletionRate` use case + tests

### Settings Use Cases
- [ ] `GetSettings` use case + tests
- [ ] `UpdateIntervalDuration` use case + tests
- [ ] `ToggleNotifications` use case + tests
- [ ] `ToggleVoiceInput` use case + tests

### Categories Use Cases
- [ ] `CategorizeLog` use case + tests
- [ ] `GetAllCategories` use case + tests
- [ ] `CreateCategory` use case + tests

### Insights Use Cases
- [ ] `GenerateDailyInsight` use case + tests
- [ ] `GetTopActivities` use case + tests
- [ ] `CalculateCompletionRate` use case + tests

### Streaks Use Cases
- [ ] `GetCurrentStreak` use case + tests
- [ ] `UpdateStreak` use case + tests

### Export Use Cases
- [ ] `ExportToCSV` use case + tests
- [ ] `ExportToJSON` use case + tests

**Estimated Time:** 2-3 days
**Total Progress: 0/24 use cases**

---

## PHASE 5: Dependency Injection

**Goal:** Setup GetIt for dependency injection

- [ ] Create `lib/core/di/injection.dart`
- [ ] Register database singleton
- [ ] Register all DAOs
- [ ] Register all repositories
- [ ] Register all use cases
- [ ] Register all Blocs (factory pattern)
- [ ] Register services (notifications, voice)
- [ ] Call `init()` in main.dart before runApp

**Estimated Time:** 2-3 hours
**Total Progress: 0%**

---

## PHASE 6: Bloc Layer (Presentation Logic)

**Goal:** Create Blocs with events/states, test-first approach

### Logging Bloc
- [ ] Define `LoggingEvent` (CreateLogEvent, LoadTodayLogsEvent, UpdateLogEvent, DeleteLogEvent)
- [ ] Define `LoggingState` (LoggingInitial, LoggingLoading, LoggingLoaded, LoggingError)
- [ ] Write `logging_bloc_test.dart` (use bloc_test package)
- [ ] Implement `LoggingBloc`
- [ ] Verify tests pass

### History Bloc
- [ ] Define `HistoryEvent` (LoadHistoryEvent, FilterByDateEvent, SearchEvent)
- [ ] Define `HistoryState` (HistoryInitial, HistoryLoading, HistoryLoaded, HistoryError)
- [ ] Write `history_bloc_test.dart`
- [ ] Implement `HistoryBloc`
- [ ] Verify tests pass

### Insights Bloc
- [ ] Define `InsightsEvent` (LoadInsightsEvent, RefreshInsightsEvent)
- [ ] Define `InsightsState` (InsightsInitial, InsightsLoading, InsightsLoaded, InsightsError)
- [ ] Write `insights_bloc_test.dart`
- [ ] Implement `InsightsBloc`
- [ ] Verify tests pass

### Settings Bloc
- [ ] Define `SettingsEvent` (LoadSettingsEvent, UpdateIntervalEvent, ToggleNotificationsEvent)
- [ ] Define `SettingsState` (SettingsInitial, SettingsLoading, SettingsLoaded, SettingsError)
- [ ] Write `settings_bloc_test.dart`
- [ ] Implement `SettingsBloc`
- [ ] Verify tests pass

### Onboarding Bloc
- [ ] Define `OnboardingEvent` (CompleteWelcomeEvent, SelectIntervalEvent, RequestPermissionsEvent)
- [ ] Define `OnboardingState` (OnboardingInitial, OnboardingInProgress, OnboardingComplete)
- [ ] Write `onboarding_bloc_test.dart`
- [ ] Implement `OnboardingBloc`
- [ ] Verify tests pass

**Estimated Time:** 2-3 days
**Total Progress: 0/5 blocs**

---

## PHASE 7: Navigation Setup

**Goal:** Configure go_router for app navigation

- [ ] Create `lib/shared/navigation/app_router.dart`
- [ ] Define onboarding routes (/welcome, /interval-selection, /permissions)
- [ ] Define main app routes with ShellRoute (bottom nav)
  - /logging (home)
  - /history
  - /insights
  - /settings
- [ ] Implement redirect logic (check onboarding status)
- [ ] Setup deep linking configuration
- [ ] Test navigation flow

**Estimated Time:** 3-4 hours
**Total Progress: 0%**

---

## PHASE 8: UI - Shared Widgets

**Goal:** Create reusable UI components

- [ ] `shared/widgets/custom_button.dart` (minimalist black button)
- [ ] `shared/widgets/custom_text_input.dart` (auto-focus, character counter)
- [ ] `shared/widgets/custom_card.dart` (flat design, no elevation)
- [ ] `shared/widgets/loading_spinner.dart` (black spinner)
- [ ] `shared/widgets/error_view.dart` (simple error display)
- [ ] `shared/widgets/fade_in_view.dart` (animation wrapper)

**Estimated Time:** 4-6 hours
**Total Progress: 0/6 widgets**

---

## PHASE 9: UI - Onboarding Screens

**Goal:** Implement onboarding flow

- [ ] Create `WelcomeScreen` (minimalist intro)
- [ ] Create `IntervalSelectionScreen` (15min/30min choice)
- [ ] Create `PermissionsScreen` (request notification permissions)
- [ ] Wire up OnboardingBloc
- [ ] Add navigation between screens
- [ ] Test onboarding flow end-to-end

**Estimated Time:** 1 day
**Total Progress: 0/3 screens**

---

## PHASE 10: UI - Logging Screen (Core Feature)

**Goal:** Implement main logging screen

- [ ] Create `LoggingScreen` layout (home screen)
- [ ] Build text input widget (auto-focus)
- [ ] Build voice recorder widget
- [ ] Display recent logs preview
- [ ] Wire up LoggingBloc
- [ ] Add haptic feedback on log creation
- [ ] Add loading/error states
- [ ] Test logging flow (text and voice)

**Estimated Time:** 1-2 days
**Total Progress: 0%**

---

## PHASE 11: UI - History Screen

**Goal:** View and edit past logs

- [ ] Create `HistoryScreen` layout
- [ ] Build log list item widget
- [ ] Add pull-to-refresh
- [ ] Implement calendar view
- [ ] Create edit log modal
- [ ] Wire up HistoryBloc
- [ ] Add search functionality
- [ ] Add delete with swipe gesture

**Estimated Time:** 1-2 days
**Total Progress: 0%**

---

## PHASE 12: UI - Insights Screen

**Goal:** Display analytics and charts

- [ ] Create `InsightsScreen` layout
- [ ] Build insight card widgets
- [ ] Implement charts with fl_chart
  - Completion rate chart
  - Top activities chart
  - Category distribution
- [ ] Display stats: total logs, streak, completion rate
- [ ] Wire up InsightsBloc
- [ ] Add refresh functionality

**Estimated Time:** 1-2 days
**Total Progress: 0%**

---

## PHASE 13: UI - Settings Screen

**Goal:** App configuration

- [ ] Create `SettingsScreen` layout
- [ ] Add interval duration toggle (15/30 min)
- [ ] Add notifications toggle
- [ ] Add voice input toggle
- [ ] Add theme selector (light/dark)
- [ ] Add export buttons (CSV/JSON)
- [ ] Add about section (version, credits)
- [ ] Wire up SettingsBloc

**Estimated Time:** 1 day
**Total Progress: 0%**

---

## PHASE 14: Notification System

**Goal:** Setup background notifications

### Setup
- [ ] Configure flutter_local_notifications
- [ ] Initialize notification channels (Android)
- [ ] Request permissions (iOS/Android)
- [ ] Setup timezone for scheduling

### Implementation
- [ ] Create NotificationService
- [ ] Implement interval-based scheduling
- [ ] Add quick action buttons (Text/Voice/Skip)
- [ ] Handle notification tap → deep link to LoggingScreen
- [ ] Create IntervalRepository methods for tracking responses

### Platform-Specific
- [ ] Configure Android WorkManager for background scheduling
- [ ] Configure iOS background modes
- [ ] Test on real devices

**Estimated Time:** 2-3 days
**Total Progress: 0%**

---

## PHASE 15: Voice Recording & Transcription

**Goal:** Implement voice input feature

- [ ] Create VoiceService using speech_to_text
- [ ] Implement recording with record package
- [ ] Add microphone permission handling
- [ ] Create VoiceRecorderWidget UI
  - Recording animation
  - Stop button
  - Transcription display
- [ ] Test on real devices (on-device transcription)

**Estimated Time:** 1-2 days
**Total Progress: 0%**

---

## PHASE 16: Testing & Polish

**Goal:** Comprehensive testing and refinements

### Testing
- [ ] Verify all unit tests passing (repositories, use cases)
- [ ] Verify all bloc tests passing
- [ ] Write widget tests for critical screens
- [ ] Write integration tests for core flows
- [ ] Test on Android device
- [ ] Test on iOS device

### Polish
- [ ] Add loading states everywhere
- [ ] Implement proper error handling
- [ ] Add haptic feedback throughout
- [ ] Add subtle animations (fade-ins, transitions)
- [ ] Performance optimization
- [ ] Accessibility improvements (screen reader support)

**Estimated Time:** 2-3 days
**Total Progress: 0%**

---

## PHASE 17: Platform Configuration & Build

**Goal:** Prepare for production

### Configuration
- [ ] Configure app icons (Android/iOS)
- [ ] Configure splash screen
- [ ] Update AndroidManifest.xml (permissions, deep linking)
- [ ] Update Info.plist (permissions, URL schemes)
- [ ] Configure build.gradle (version, signing)

### Build
- [ ] Build Android APK/AAB
- [ ] Build iOS IPA
- [ ] Test release builds on real devices

**Estimated Time:** 1 day
**Total Progress: 0%**

---

## Summary Progress

| Phase | Status | Progress | Est. Time |
|-------|--------|----------|-----------|
| 1. Core Infrastructure | ✅ Complete | 100% | - |
| 2. Repository Interfaces | 📍 Current | 0% | 2-3 hours |
| 3. Repository Tests + Impl | ⏳ Next | 0% | 1-2 days |
| 4. Use Cases | ⏳ Pending | 0% | 2-3 days |
| 5. Dependency Injection | ⏳ Pending | 0% | 2-3 hours |
| 6. Blocs | ⏳ Pending | 0% | 2-3 days |
| 7. Navigation | ⏳ Pending | 0% | 3-4 hours |
| 8. Shared Widgets | ⏳ Pending | 0% | 4-6 hours |
| 9. Onboarding UI | ⏳ Pending | 0% | 1 day |
| 10. Logging UI | ⏳ Pending | 0% | 1-2 days |
| 11. History UI | ⏳ Pending | 0% | 1-2 days |
| 12. Insights UI | ⏳ Pending | 0% | 1-2 days |
| 13. Settings UI | ⏳ Pending | 0% | 1 day |
| 14. Notifications | ⏳ Pending | 0% | 2-3 days |
| 15. Voice | ⏳ Pending | 0% | 1-2 days |
| 16. Testing & Polish | ⏳ Pending | 0% | 2-3 days |
| 17. Platform & Build | ⏳ Pending | 0% | 1 day |

**Overall Progress: Phase 1 Complete (6% total)**
**Estimated Time to Complete: 4-5 weeks**

---

## Immediate Next Steps (Phase 2)

1. **Create repository interfaces** for all 7 features
2. **Start with LogRepository** (most critical)
3. **Follow with other repositories** in order of importance

Ready to proceed? 🚀
