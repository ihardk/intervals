# Screen Time Features Implementation Plan

**Date:** 2025-12-13
**Features:** App Blocking + Awareness Gap Analysis + Pomodoro Focus Mode
**Status:** Planning Phase

---

## 🎯 Feature Overview

### 1. App Blocking
Block distracting apps during logged focus sessions to enforce intentional behavior.

### 2. Awareness Gap Analysis
Compare what users log ("working") vs actual app usage ("30% social media") to reveal self-awareness gaps.

### 3. Pomodoro Focus Mode
Integrate Pomodoro technique (25 min work / 5 min break) with automatic app blocking during work sessions.

### 4. Habit Tracker
Simple daily habit tracking with streak monitoring and Pomodoro integration.

### 5. Top Priorities (Daily Top 3)
Minimalist daily priority list (max 3-5) with Pomodoro and logging integration.

---

## 🏗️ Architecture Design

### New Feature Module: `screen_time`

```
flutter/lib/features/screen_time/
├── domain/
│   ├── entities/
│   │   ├── app_usage.dart                    # Freezed entity for app usage data
│   │   ├── app_block_rule.dart               # Freezed entity for blocking rules
│   │   ├── awareness_gap.dart                # Freezed entity for gap analysis
│   │   └── pomodoro_session.dart             # Freezed entity for Pomodoro sessions
│   ├── repositories/
│   │   ├── screen_time_repository.dart       # Abstract interface
│   │   └── app_blocker_repository.dart       # Abstract interface
│   └── usecases/
│       ├── get_app_usage_usecase.dart        # Fetch app usage for date range
│       ├── get_daily_screen_time_usecase.dart
│       ├── create_block_rule_usecase.dart    # Create app blocking rule
│       ├── enable_block_rule_usecase.dart    # Enable/disable blocking
│       ├── get_active_blocks_usecase.dart    # Get currently blocked apps
│       ├── calculate_awareness_gap_usecase.dart  # Compare logs vs reality
│       ├── start_pomodoro_usecase.dart       # Start Pomodoro work session
│       ├── complete_pomodoro_usecase.dart    # Complete work/break session
│       ├── pause_pomodoro_usecase.dart       # Pause active session
│       ├── skip_break_usecase.dart           # Skip break, start next work
│       └── get_pomodoro_stats_usecase.dart   # Get daily/weekly Pomodoro stats
├── data/
│   ├── models/
│   │   ├── app_usage_model.dart              # Drift ↔ Domain conversion
│   │   ├── app_block_rule_model.dart
│   │   └── pomodoro_session_model.dart       # Pomodoro Drift model
│   ├── services/
│   │   ├── screen_time_service.dart          # Platform-specific (app_usage package)
│   │   ├── app_blocker_service.dart          # Platform-specific blocking
│   │   └── pomodoro_timer_service.dart       # Timer with notifications
│   └── repositories/
│       ├── screen_time_repository_impl.dart  # Either pattern
│       ├── app_blocker_repository_impl.dart
│       └── pomodoro_repository_impl.dart     # Pomodoro session management
└── presentation/
    ├── bloc/
    │   ├── screen_time_bloc.dart             # Events: LoadUsage, RefreshUsage
    │   ├── app_blocker_bloc.dart             # Events: CreateRule, ToggleBlock
    │   ├── awareness_gap_bloc.dart           # Events: CalculateGap, LoadGaps
    │   └── pomodoro_bloc.dart                # Events: Start, Pause, Complete, Tick
    ├── pages/
    │   ├── screen_time_page.dart             # New tab or insights integration
    │   ├── app_blocker_settings_page.dart
    │   └── pomodoro_page.dart                # Focus mode with timer
    └── widgets/
        ├── app_usage_chart.dart              # Bar chart of app usage
        ├── awareness_gap_card.dart           # Shows discrepancy
        ├── block_rule_list.dart              # List of blocking rules
        ├── app_selector.dart                 # Select apps to block
        ├── pomodoro_timer.dart               # Circular timer widget
        ├── pomodoro_controls.dart            # Start/Pause/Skip buttons
        └── pomodoro_stats_card.dart          # Daily completed sessions
```

---

## 📊 Database Schema Updates

### New Tables (Drift)

**1. `app_usage` table**
```dart
@DataClassName('AppUsageData')
class AppUsage extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();          // com.instagram.android
  TextColumn get appName => text()();              // Instagram
  TextColumn get category => text().nullable()();  // social_media, productivity
  IntColumn get usageTimeMs => integer()();        // Milliseconds of usage
  IntColumn get date => integer()();               // Unix timestamp (start of day)
  IntColumn get lastForeground => integer()();     // Last time app was in foreground
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

**2. `app_block_rules` table**
```dart
@DataClassName('AppBlockRuleData')
class AppBlockRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ruleName => text()();             // "Focus Mode", "Deep Work"
  TextColumn get blockedApps => text()();          // JSON array of package names
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get triggerType => text()();          // "manual", "during_log_category"
  TextColumn get triggerValue => text().nullable()(); // "Work" category
  IntColumn get startTime => integer().nullable()(); // Time of day (minutes from midnight)
  IntColumn get endTime => integer().nullable()();
  TextColumn get daysOfWeek => text().nullable()(); // JSON array [1,2,3,4,5] for Mon-Fri
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

**3. `awareness_gaps` table**
```dart
@DataClassName('AwarenessGapData')
class AwarenessGaps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get logId => integer()();              // Foreign key to logs table
  TextColumn get loggedActivity => text()();       // "Working on code"
  TextColumn get loggedCategory => text()();       // "Work"
  IntColumn get logTimestamp => integer()();       // When log was created
  TextColumn get actualAppsUsed => text()();       // JSON: [{app, time, %}, ...]
  IntColumn get gapScore => integer()();           // 0-100 (0=perfect match, 100=total mismatch)
  TextColumn get gapType => text()();              // "distraction", "mismatch", "aligned"
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

**4. `pomodoro_sessions` table**
```dart
@DataClassName('PomodoroSessionData')
class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionType => text()();          // "work", "short_break", "long_break"
  IntColumn get durationMinutes => integer()();    // 25, 5, 15
  IntColumn get startTime => integer()();          // Unix timestamp
  IntColumn get endTime => integer().nullable()(); // Unix timestamp (null if incomplete)
  TextColumn get status => text()();               // "active", "completed", "paused", "skipped"
  IntColumn get pausedAt => integer().nullable()(); // When paused
  IntColumn get pausedDuration => integer().withDefault(const Constant(0))(); // Total pause time
  BoolColumn get wasInterrupted => boolean().withDefault(const Constant(false))();
  IntColumn get interruptions => integer().withDefault(const Constant(0))(); // Count of distractions
  TextColumn get tags => text().nullable()();      // JSON array: ["deep-work", "coding"]
  TextColumn get category => text().nullable()();  // Link to log category
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### DAOs to Create

```dart
@DriftAccessor(tables: [AppUsage, AppBlockRules, AwarenessGaps, PomodoroSessions])
class ScreenTimeDao extends DatabaseAccessor<AppDatabase> with _$ScreenTimeDaoMixin {
  Future<List<AppUsageData>> getAppUsageForDate(DateTime date);
  Future<List<AppUsageData>> getAppUsageForDateRange(DateTime start, DateTime end);
  Future<AppUsageData?> getAppUsageByPackage(String packageName, DateTime date);
  Future<int> insertAppUsage(AppUsageCompanion appUsage);
  Future<void> updateAppUsage(AppUsageData appUsage);

  Future<List<AppBlockRuleData>> getAllBlockRules();
  Future<List<AppBlockRuleData>> getActiveBlockRules();
  Future<AppBlockRuleData?> getBlockRuleById(int id);
  Future<int> insertBlockRule(AppBlockRulesCompanion rule);
  Future<void> updateBlockRule(AppBlockRuleData rule);
  Future<void> deleteBlockRule(int id);

  Future<List<AwarenessGapData>> getAwarenessGapsForDateRange(DateTime start, DateTime end);
  Future<AwarenessGapData?> getAwarenessGapForLog(int logId);
  Future<int> insertAwarenessGap(AwarenessGapsCompanion gap);

  Future<List<PomodoroSessionData>> getPomodoroSessionsForDate(DateTime date);
  Future<List<PomodoroSessionData>> getPomodoroSessionsForDateRange(DateTime start, DateTime end);
  Future<PomodoroSessionData?> getActiveSession();
  Future<int> getCompletedSessionsCount(DateTime date);
  Future<int> insertPomodoroSession(PomodoroSessionsCompanion session);
  Future<void> updatePomodoroSession(PomodoroSessionData session);
}
```

---

## 🔧 Technical Implementation

### 1. App Blocking Implementation

**Platform Considerations:**

**Android (✅ Feasible):**
- **Approach 1**: Accessibility Service (overlay blocking screen)
  - Show fullscreen overlay when blocked app opens
  - Detect app launch via AccessibilityService
  - User can dismiss with delay (e.g., "Are you sure? Wait 10s")

- **Approach 2**: UsageStats polling + overlay
  - Poll UsageStatsManager every 1-2 seconds
  - When blocked app detected in foreground → show overlay
  - Lighter weight than Accessibility Service

- **Approach 3**: Digital Wellbeing API (Android 9+)
  - Requires device manufacturer support
  - Not reliable across all devices

**Recommended: Approach 2 (UsageStats polling)**

**iOS (❌ Very Limited):**
- ScreenTime API requires special entitlement (difficult to get)
- FamilyControls framework (iOS 15+) but limited
- **Alternative**: Show notification reminders instead of hard blocking

**Implementation Details (Android):**

```dart
// lib/features/screen_time/data/services/app_blocker_service.dart

class AppBlockerService {
  final AppUsage _appUsage;
  Timer? _monitoringTimer;
  final _blockedApps = <String>{};

  // Start monitoring
  Future<void> startMonitoring(List<String> blockedPackages) async {
    _blockedApps.addAll(blockedPackages);

    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkForegroundApp(),
    );
  }

  Future<void> _checkForegroundApp() async {
    final now = DateTime.now();
    final usageInfo = await _appUsage.getAppUsage(
      now.subtract(const Duration(seconds: 3)),
      now,
    );

    // Find most recently used app
    final currentApp = usageInfo.values
        .reduce((a, b) => a.lastTimeUsed.isAfter(b.lastTimeUsed) ? a : b);

    if (_blockedApps.contains(currentApp.packageName)) {
      await _showBlockOverlay(currentApp.appName);
    }
  }

  Future<void> _showBlockOverlay(String appName) async {
    // Show system overlay or navigate to blocking screen
    // Option 1: Flutter overlay (requires overlay permission)
    // Option 2: Navigate to blocking page in app
    await _notificationService.showBlockNotification(appName);
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _blockedApps.clear();
  }
}
```

### 2. Awareness Gap Analysis Implementation

**Algorithm:**

```dart
// lib/features/screen_time/domain/usecases/calculate_awareness_gap_usecase.dart

class CalculateAwarenessGapUseCase {
  Future<Either<Failure, AwarenessGap>> call({
    required Log log,
    required List<AppUsage> actualUsage,
  }) async {
    // 1. Get time window around log (±7.5 min for 15-min intervals)
    final logTime = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
    final intervalStart = logTime.subtract(const Duration(minutes: 7));
    final intervalEnd = logTime.add(const Duration(minutes: 7));

    // 2. Filter app usage to this window
    final relevantUsage = actualUsage.where((usage) {
      final usageTime = DateTime.fromMillisecondsSinceEpoch(usage.lastForeground);
      return usageTime.isAfter(intervalStart) && usageTime.isBefore(intervalEnd);
    }).toList();

    // 3. Categorize actual app usage
    final usageByCategory = _categorizeAppUsage(relevantUsage);

    // 4. Compare logged category with actual usage
    final gapScore = _calculateGapScore(
      loggedCategory: log.category,
      actualUsage: usageByCategory,
    );

    // 5. Determine gap type
    final gapType = _determineGapType(gapScore, log.category, usageByCategory);

    return Right(AwarenessGap(
      logId: log.id,
      loggedActivity: log.content,
      loggedCategory: log.category,
      actualAppsUsed: usageByCategory,
      gapScore: gapScore,
      gapType: gapType,
    ));
  }

  int _calculateGapScore(String? loggedCategory, Map<String, int> actualUsage) {
    // Example: Logged "Work" but spent 60% time on social media = high gap
    if (loggedCategory == null) return 0;

    final totalTime = actualUsage.values.fold(0, (sum, time) => sum + time);
    if (totalTime == 0) return 0;

    // Get expected category for logged activity
    final expectedCategory = _mapLogCategoryToAppCategory(loggedCategory);
    final timeInExpectedCategory = actualUsage[expectedCategory] ?? 0;
    final percentageMatch = (timeInExpectedCategory / totalTime * 100).round();

    // Gap score = 100 - percentage match
    return 100 - percentageMatch;
  }

  String _determineGapType(int gapScore, String? loggedCategory, Map<String, int> actualUsage) {
    if (gapScore < 20) return 'aligned';      // <20% gap = good
    if (gapScore < 50) return 'minor_mismatch'; // 20-50% gap = minor

    // Check if it's distraction (logged work, used social media)
    final totalTime = actualUsage.values.fold(0, (sum, time) => sum + time);
    final distractingTime = actualUsage['social_media'] ?? 0;

    if (loggedCategory == 'Work' && distractingTime / totalTime > 0.3) {
      return 'distraction';
    }

    return 'major_mismatch';
  }
}
```

**Awareness Gap Visualization:**

```dart
// lib/features/screen_time/presentation/widgets/awareness_gap_card.dart

class AwarenessGapCard extends StatelessWidget {
  final AwarenessGap gap;

  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(_getGapIcon(gap.gapType)),
              Text('Awareness Check'),
              Spacer(),
              Text('${gap.gapScore}% gap'),
            ],
          ),

          // What you logged
          Text('You logged: "${gap.loggedActivity}"'),
          Text('Category: ${gap.loggedCategory}'),

          // What you actually did
          Text('But you actually used:'),
          ...gap.actualAppsUsed.entries.map((e) {
            final percent = (e.value / gap.totalTime * 100).round();
            return Row(
              children: [
                Text(e.key),
                Spacer(),
                Text('$percent%'),
              ],
            );
          }),

          // Insight
          if (gap.gapType == 'distraction')
            Text(
              '⚠️ Distraction detected! You logged work but spent significant time on social media.',
              style: TextStyle(color: Colors.orange),
            ),
        ],
      ),
    );
  }
}
```

### 3. Pomodoro Focus Mode Implementation

**Pomodoro Technique:**
- **Work Session**: 25 minutes of focused work
- **Short Break**: 5 minutes rest
- **Long Break**: 15 minutes rest (after 4 work sessions)
- **Auto-blocking**: Apps automatically blocked during work sessions

**Implementation:**

```dart
// lib/features/screen_time/data/services/pomodoro_timer_service.dart

class PomodoroTimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  PomodoroSessionType _currentType = PomodoroSessionType.work;
  final _tickController = StreamController<int>.broadcast();
  final _sessionCompleteController = StreamController<PomodoroSession>.broadcast();

  Stream<int> get tickStream => _tickController.stream;
  Stream<PomodoroSession> get sessionCompleteStream => _sessionCompleteController.stream;

  Future<void> startSession({
    required PomodoroSessionType type,
    int? customDuration,
  }) async {
    _currentType = type;
    _remainingSeconds = customDuration ?? _getDefaultDuration(type);

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      _tickController.add(_remainingSeconds);

      if (_remainingSeconds <= 0) {
        _onSessionComplete();
      }
    });

    // Enable app blocking during work sessions
    if (type == PomodoroSessionType.work) {
      await _enableFocusBlocking();
    }

    // Show notification
    await _notificationService.showPomodoroStartNotification(type);
  }

  void pauseSession() {
    _timer?.cancel();
    // Keep _remainingSeconds to resume later
  }

  Future<void> resumeSession() async {
    if (_remainingSeconds > 0) {
      await startSession(
        type: _currentType,
        customDuration: _remainingSeconds,
      );
    }
  }

  Future<void> skipToBreak() async {
    _timer?.cancel();
    await _disableFocusBlocking();
    await startSession(type: PomodoroSessionType.shortBreak);
  }

  void _onSessionComplete() {
    _timer?.cancel();

    // Disable blocking
    if (_currentType == PomodoroSessionType.work) {
      _disableFocusBlocking();
    }

    // Emit completion event
    _sessionCompleteController.add(PomodoroSession(
      type: _currentType,
      durationMinutes: _getDefaultDuration(_currentType) ~/ 60,
      status: PomodoroSessionStatus.completed,
    ));

    // Show completion notification
    _notificationService.showPomodoroCompleteNotification(_currentType);

    // Suggest next session
    _suggestNextSession();
  }

  void _suggestNextSession() {
    // After work → suggest break
    // After break → suggest work
    final nextType = _currentType == PomodoroSessionType.work
        ? PomodoroSessionType.shortBreak
        : PomodoroSessionType.work;

    _notificationService.showNextSessionSuggestion(nextType);
  }

  Future<void> _enableFocusBlocking() async {
    // Enable predefined "Focus Mode" blocking rule
    final focusRule = await _blockRuleRepository.getRuleByName('Focus Mode');
    if (focusRule != null) {
      await _appBlockerService.startMonitoring(focusRule.blockedApps);
    }
  }

  Future<void> _disableFocusBlocking() async {
    await _appBlockerService.stopMonitoring();
  }

  int _getDefaultDuration(PomodoroSessionType type) {
    switch (type) {
      case PomodoroSessionType.work:
        return 25 * 60; // 25 minutes
      case PomodoroSessionType.shortBreak:
        return 5 * 60; // 5 minutes
      case PomodoroSessionType.longBreak:
        return 15 * 60; // 15 minutes
    }
  }

  void dispose() {
    _timer?.cancel();
    _tickController.close();
    _sessionCompleteController.close();
  }
}
```

**Pomodoro UI:**

```dart
// lib/features/screen_time/presentation/widgets/pomodoro_timer.dart

class PomodoroTimer extends StatelessWidget {
  final int remainingSeconds;
  final PomodoroSessionType sessionType;
  final bool isActive;

  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Container(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          CircularProgressIndicator(
            value: _getProgress(),
            strokeWidth: 12,
            backgroundColor: AppColors.grey3,
            valueColor: AlwaysStoppedAnimation(_getSessionColor(sessionType)),
          ),

          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$minutes:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _getSessionLabel(sessionType),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getProgress() {
    final totalDuration = _getTotalDuration(sessionType);
    return remainingSeconds / totalDuration;
  }

  Color _getSessionColor(PomodoroSessionType type) {
    switch (type) {
      case PomodoroSessionType.work:
        return Colors.red;
      case PomodoroSessionType.shortBreak:
        return Colors.green;
      case PomodoroSessionType.longBreak:
        return Colors.blue;
    }
  }

  String _getSessionLabel(PomodoroSessionType type) {
    switch (type) {
      case PomodoroSessionType.work:
        return 'FOCUS TIME';
      case PomodoroSessionType.shortBreak:
        return 'SHORT BREAK';
      case PomodoroSessionType.longBreak:
        return 'LONG BREAK';
    }
  }
}
```

**Pomodoro Page UI:**

```
┌─────────────────────────────┐
│ Focus Mode 🍅               │
├─────────────────────────────┤
│                             │
│    ┌───────────────────┐    │
│    │                   │    │
│    │                   │    │
│    │      23:45        │    │
│    │    FOCUS TIME     │    │
│    │                   │    │
│    │                   │    │
│    └───────────────────┘    │
│                             │
│   [Start]  [Pause]  [Skip]  │
│                             │
│ Today's Sessions: 4/8 🍅    │
│ ████████░░░░░░░░            │
│                             │
│ Session History             │
│ ✅ 9:00 - 9:25 Work         │
│ ✅ 9:30 - 9:35 Break        │
│ ✅ 9:40 - 10:05 Work        │
│ ⏸️ 10:10 - (paused)         │
│                             │
│ Settings                    │
│ Work: 25 min  [Edit]        │
│ Break: 5 min  [Edit]        │
│ Auto-block apps: [ON]       │
│ Sound alerts: [ON]          │
└─────────────────────────────┘
```

**Integration with App Blocking:**

When a Pomodoro work session starts:
1. Automatically enable "Focus Mode" block rule
2. Block distracting apps (social media, games)
3. User receives notification: "Focus Mode active - stay focused!"
4. If user tries to open blocked app during session:
   - Show overlay: "You're in Pomodoro! 23 min remaining"
   - Options: "Take a break?" or "Continue focus"

**Pomodoro Statistics:**

Track and display:
- Total completed sessions per day/week/month
- Success rate (completed vs skipped)
- Average session length
- Most productive time of day
- Longest focus streak

---

## 🧪 Testing Strategy

### Domain Layer Tests (BDD)

**CalculateAwarenessGapUseCase Tests:**
```dart
group('CalculateAwarenessGapUseCase', () {
  test('should return aligned gap when logged work matches actual productivity apps', () async {
    // Arrange
    final log = Log(category: 'Work', content: 'Coding', timestamp: ...);
    final actualUsage = [
      AppUsage(appName: 'VS Code', category: 'productivity', usageTimeMs: 600000), // 10 min
      AppUsage(appName: 'Chrome', category: 'productivity', usageTimeMs: 300000),  // 5 min
    ];

    // Act
    final result = await useCase(log: log, actualUsage: actualUsage);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not fail'),
      (gap) {
        expect(gap.gapScore, lessThan(20)); // <20% gap
        expect(gap.gapType, 'aligned');
      },
    );
  });

  test('should return distraction gap when logged work but used social media', () async {
    // Arrange
    final log = Log(category: 'Work', content: 'Working on project', timestamp: ...);
    final actualUsage = [
      AppUsage(appName: 'Instagram', category: 'social_media', usageTimeMs: 600000), // 10 min
      AppUsage(appName: 'VS Code', category: 'productivity', usageTimeMs: 200000),   // 3 min
    ];

    // Act
    final result = await useCase(log: log, actualUsage: actualUsage);

    // Assert
    result.fold(
      (failure) => fail('Should not fail'),
      (gap) {
        expect(gap.gapScore, greaterThan(50)); // >50% gap
        expect(gap.gapType, 'distraction');
      },
    );
  });
});
```

**CreateBlockRuleUseCase Tests:**
```dart
group('CreateBlockRuleUseCase', () {
  test('should create block rule with valid apps', () async {
    // Arrange
    final rule = AppBlockRule(
      ruleName: 'Focus Mode',
      blockedApps: ['com.instagram.android', 'com.facebook.katana'],
      triggerType: 'manual',
      isEnabled: true,
    );

    // Act
    final result = await useCase(rule);

    // Assert
    expect(result.isRight(), true);
  });

  test('should fail when rule name is empty', () async {
    // Arrange
    final rule = AppBlockRule(ruleName: '', blockedApps: ['com.instagram.android']);

    // Act
    final result = await useCase(rule);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Should fail validation'),
    );
  });
});
```

---

## 🎨 UI/UX Design

### New Screens

**1. Screen Time Page (New Tab or Insights Integration)**

```
┌─────────────────────────────┐
│ Screen Time                 │
├─────────────────────────────┤
│ Today's Usage: 4h 23m       │
│                             │
│ [App Usage Chart]           │
│ Instagram    1h 30m  ████   │
│ Chrome       1h 15m  ███    │
│ VS Code      45m     ██     │
│ Slack        33m     █      │
│                             │
│ Awareness Gaps (3)          │
│ ┌─────────────────────────┐ │
│ │ ⚠️ 9:15 AM             │ │
│ │ Logged: "Working"      │ │
│ │ Actually: 60% social   │ │
│ │ Gap: 73% distraction   │ │
│ └─────────────────────────┘ │
│                             │
│ [Manage Blocking Rules]     │
└─────────────────────────────┘
```

**2. App Blocker Settings Page**

```
┌─────────────────────────────┐
│ App Blocking Rules          │
├─────────────────────────────┤
│ Active Rules                │
│                             │
│ ┌─────────────────────────┐ │
│ │ Focus Mode         [ON] │ │
│ │ Blocks: Instagram, FB   │ │
│ │ Trigger: Manual         │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ Deep Work         [OFF] │ │
│ │ Blocks: All social      │ │
│ │ Trigger: "Work" logs    │ │
│ │ Time: 9am-5pm Weekdays  │ │
│ └─────────────────────────┘ │
│                             │
│ [+ Create New Rule]         │
└─────────────────────────────┘
```

**3. Block Overlay Screen (When Blocked App Opened)**

```
┌─────────────────────────────┐
│                             │
│         🚫                  │
│    Instagram Blocked        │
│                             │
│  "Focus Mode" is active     │
│                             │
│  You're in a Work session   │
│  Stay focused!              │
│                             │
│                             │
│ [Take a Break (15s)]        │
│ [I Really Need This (30s)]  │
│                             │
│ Blocked for 2h 15m          │
└─────────────────────────────┘
```

---

## 📦 Dependencies to Add

```yaml
dependencies:
  # Screen time tracking (Android)
  app_usage: ^3.0.0           # Android UsageStatsManager wrapper

  # Overlay permissions (Android blocking)
  flutter_overlay_window: ^0.4.0  # For blocking overlay

  # Device apps list
  device_apps: ^2.2.0         # Get installed apps list

  # Background service (for continuous monitoring)
  flutter_background_service: ^5.0.0

  # System alert window permission
  system_alert_window: ^2.0.1
```

---

## 📋 Implementation Phases

### Phase 1: Foundation (2-3 days)
- [ ] Add database tables (app_usage, app_block_rules, awareness_gaps, pomodoro_sessions)
- [ ] Create DAOs with tests (86+ tests pattern)
- [ ] Define domain entities (Freezed): AppUsage, AppBlockRule, AwarenessGap, PomodoroSession
- [ ] Setup dependencies (app_usage, device_apps, background_service packages)

### Phase 2: Screen Time Tracking (2 days)
- [ ] Implement ScreenTimeService (Android)
- [ ] Create repository interface + implementation
- [ ] Write use cases + BDD tests
  - [ ] GetAppUsageUseCase
  - [ ] GetDailyScreenTimeUseCase
- [ ] Create ScreenTimeBloc + tests
- [ ] Build Screen Time UI (charts, app list)

### Phase 3: Awareness Gap Analysis (2-3 days)
- [ ] Implement CalculateAwarenessGapUseCase + tests
- [ ] Create awareness gap calculation algorithm
- [ ] Build AwarenessGapBloc + tests
- [ ] Design awareness gap UI components
- [ ] Integrate with existing logging flow
- [ ] Add gap notifications/insights

### Phase 4: App Blocking (3-4 days)
- [ ] Implement AppBlockerService (polling approach)
- [ ] Create block rule repository + use cases
  - [ ] CreateBlockRuleUseCase
  - [ ] EnableBlockRuleUseCase
  - [ ] GetActiveBlocksUseCase
- [ ] Build AppBlockerBloc + tests
- [ ] Request necessary permissions (UsageStats, Overlay)
- [ ] Build blocking overlay screen
- [ ] Create block rule management UI
- [ ] Add trigger logic (manual, during log category)

### Phase 5: Pomodoro Focus Mode (2-3 days)
- [ ] Implement PomodoroTimerService with Stream-based timer
- [ ] Create Pomodoro repository + use cases
  - [ ] StartPomodoroUseCase
  - [ ] CompletePomodoroUseCase
  - [ ] PausePomodoroUseCase
  - [ ] SkipBreakUseCase
  - [ ] GetPomodoroStatsUseCase
- [ ] Build PomodoroBloc + tests (events: Start, Pause, Resume, Complete, Tick)
- [ ] Design Pomodoro UI (circular timer, controls, stats)
- [ ] Integrate Pomodoro with app blocking (auto-enable during work sessions)
- [ ] Add Pomodoro notifications (start, complete, break suggestions)
- [ ] Build session history view
- [ ] Add customizable durations (work/break lengths)

### Phase 6: Integration (2 days)
- [ ] Integrate with existing Insights page
- [ ] Add Screen Time tab to bottom navigation (optional)
- [ ] Connect blocking with logging (auto-enable during Work logs)
- [ ] Add settings for screen time features
- [ ] Polish UI/UX

### Phase 7: Testing & Polish (2 days)
- [ ] Integration testing
- [ ] Manual testing on multiple Android devices
- [ ] Permission flow testing
- [ ] Performance optimization (polling frequency)
- [ ] Documentation updates

### Phase 8: Habits & Priorities (3-4 days)
- [ ] Create habits and priorities database tables
- [ ] Implement Habit domain layer (5 use cases + tests)
- [ ] Implement Priority domain layer (5 use cases + tests)
- [ ] Build HabitBloc + tests
- [ ] Build PriorityBloc + tests
- [ ] Design Habits page UI (list, check-off, stats)
- [ ] Design Priorities page UI (daily top 3, Pomodoro links)
- [ ] Integrate habits with Pomodoro (link sessions to habits)
- [ ] Integrate priorities with Pomodoro (track sessions per priority)
- [ ] Add habit/priority widgets to launcher home screen

### Phase 9: Launcher (4-5 days)
- [ ] Add HOME intent filter to AndroidManifest
- [ ] Integrate device_apps package
- [ ] Create InstalledAppsService
- [ ] Build LauncherHomePage with app grid
- [ ] Add Pomodoro status widget to launcher
- [ ] Add Habits quick-check widget to launcher
- [ ] Add Priorities widget to launcher
- [ ] Filter/dim blocked apps during focus mode
- [ ] Track all app launches
- [ ] App categorization (productive vs distracting)
- [ ] Test launcher selection flow

### Phase 10: Final Integration (2 days)
- [ ] Connect all features (Pomodoro ↔ Habits ↔ Priorities ↔ Launcher)
- [ ] End-of-day review screen (priorities completion)
- [ ] Habit awareness gap calculations
- [ ] Polish all UIs for consistency
- [ ] Update navigation (add Habits and Priorities tabs)

### Phase 11: Testing & Polish (2-3 days)
- [ ] Integration testing (all features working together)
- [ ] Manual testing on multiple Android devices
- [ ] Permission flows testing
- [ ] Performance optimization
- [ ] Documentation updates
- [ ] User onboarding flow updates

**Total Estimated Time: 26-35 days** (~5-7 weeks)

---

## ⚠️ Challenges & Considerations

### 1. Android Permissions
- **PACKAGE_USAGE_STATS**: User must grant in Settings (can't request programmatically)
- **SYSTEM_ALERT_WINDOW**: For overlay blocking (less restricted on Android 10+)
- Need clear onboarding flow to guide users

### 2. Battery Impact
- Continuous polling (every 2s) can drain battery
- **Mitigation**: Use efficient polling, stop when screen off, optimize intervals

### 3. iOS Limitations
- Very limited screen time API access
- **Decision**: Android-only for now, iOS shows "Feature not available" with explanation

### 4. App Categorization
- Need to categorize installed apps (social media, productivity, etc.)
- **Options**:
  - Hardcoded list of popular apps
  - User manual categorization
  - API lookup (Play Store categories)

### 5. Privacy Concerns
- Tracking all app usage is sensitive
- **Mitigation**:
  - Local-only data (never sent to server)
  - Clear privacy policy
  - User can disable features
  - Transparent about what's tracked

### 6. Blocking Effectiveness
- Overlay can be dismissed (not perfect blocking like iOS ScreenTime)
- **Mitigation**: Add friction (delays, streak loss warnings)

---

## 🎯 Success Metrics

**App Blocking:**
- [ ] Successfully blocks apps 95%+ of the time
- [ ] <5% battery drain from monitoring
- [ ] <200ms detection latency
- [ ] User can create and enable rules easily

**Awareness Gap Analysis:**
- [ ] Gap calculation accuracy >90%
- [ ] Useful insights shown in Insights tab
- [ ] Users report increased self-awareness
- [ ] Clear, actionable gap notifications

---

## 🔄 Migration from Current State

**No Breaking Changes:**
- All new features are additive
- Existing functionality unchanged
- Optional features (user can disable)

**Database Migration:**
```dart
// Add to app_database.dart
@DriftDatabase(
  tables: [
    Logs,
    Intervals,
    Settings,
    Insights,
    Categories,
    Streaks,
    Exports,
    AppUsage,        // NEW
    AppBlockRules,   // NEW
    AwarenessGaps,   // NEW
  ],
)
```

**Dependency Injection Updates:**
```dart
// core/di/injection.dart
void configureDependencies() {
  // Existing registrations...

  // Screen Time
  getIt.registerLazySingleton(() => ScreenTimeService());
  getIt.registerLazySingleton(() => AppBlockerService());
  getIt.registerLazySingleton<ScreenTimeRepository>(
    () => ScreenTimeRepositoryImpl(getIt(), getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetAppUsageUseCase(getIt()));
  getIt.registerLazySingleton(() => CalculateAwarenessGapUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateBlockRuleUseCase(getIt()));

  // BLoCs
  getIt.registerFactory(() => ScreenTimeBloc(getIt(), getIt()));
  getIt.registerFactory(() => AppBlockerBloc(getIt(), getIt()));
}
```

---

## 📝 Next Steps

1. **User Approval**: ✅ Confirmed - Implement all features (App Blocking + Awareness Gap + Pomodoro)
2. **Platform Decision**: Android-only initially (iOS limitations documented)
3. **UI Integration**:
   - Add Focus Mode tab to bottom navigation
   - Integrate Awareness Gap into Insights page
   - Add Screen Time section to Settings
4. **Start Phase 1**: Database schema (4 new tables) + DAOs + entity tests

**Prioritized Features:**
1. ✅ App Blocking - Core functionality for focus enforcement
2. ✅ Awareness Gap Analysis - Reveals self-deception patterns
3. ✅ Pomodoro Timer - Structured focus sessions with auto-blocking
4. ✅ Habit Tracker - Daily habit check-offs with streaks
5. ✅ Top Priorities - Daily top 3 focus list
6. ✅ Custom Launcher - Complete home screen replacement

**Key Integration Points:**
- **Pomodoro ↔ App Blocking**: Auto-block distracting apps during work sessions
- **Pomodoro ↔ Habits**: Link Pomodoro sessions to specific habits
- **Pomodoro ↔ Priorities**: Track sessions spent on each priority
- **Habits ↔ Awareness Gap**: Compare checked habits with actual app usage
- **Priorities ↔ Manual Logs**: Tag logs with priority being worked on
- **Launcher ↔ Everything**: Home screen shows habits, priorities, Pomodoro status
- **Awareness gaps** calculated after each manual log
- **Screen time data** feeds into Insights dashboard
- All features share minimalist black/white/grey design

---

**Status:** ✅ Plan approved - Ready to start Phase 1
**Estimated Completion:** 5-7 weeks from start
**Maintains:** Clean Architecture + BDD + 100% test coverage
**New Components:**
- **8 new database tables** (app_usage, block_rules, awareness_gaps, pomodoro_sessions, habits, habit_completions, priorities, priority_pomodoro_links)
- **24+ use cases** (all with BDD tests)
- **7 BLoCs** (ScreenTime, AppBlocker, AwarenessGap, Pomodoro, Habit, Priority, Launcher)
- **5 services** (ScreenTime, AppBlocker, PomodoroTimer, InstalledApps, Launcher)
- **Custom Launcher** (full home screen replacement)
- **6 new pages** (Pomodoro, ScreenTime, AppBlocker, Habits, Priorities, Launcher)

