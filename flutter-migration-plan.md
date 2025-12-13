# Flutter Migration Plan: Interval App

## Overview
Migrate the Interval app from React Native to Flutter while preserving all features, architecture patterns, and the minimalist black/white/grey design.

## Tech Stack
- **Flutter SDK**: 3.24+ (latest stable)
- **State Management**: Bloc (flutter_bloc, bloc)
- **Database**: Drift (formerly Moor) with type-safe SQL
- **Notifications**: flutter_local_notifications
- **Navigation**: go_router (type-safe, deep linking support)
- **Voice**: speech_to_text package
- **Storage**: shared_preferences (settings cache)
- **Charts**: fl_chart (for insights visualization)
- **Audio**: record, audioplayers packages
- **File System**: path_provider
- **Haptics**: vibration or flutter_haptic_feedback
- **Share**: share_plus (for export sharing)

---

## Project Structure (Feature-First + Clean Architecture)

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # Material App with routing
│
├── core/                               # Core utilities and shared code
│   ├── constants/
│   │   ├── colors.dart                # Black/white/grey color system
│   │   ├── text_styles.dart          # Typography
│   │   ├── intervals.dart            # Interval duration constants
│   │   └── app_constants.dart        # Other constants
│   ├── theme/
│   │   └── app_theme.dart            # Minimalist theme definition
│   ├── errors/
│   │   ├── failures.dart             # Failure classes
│   │   └── exceptions.dart           # Exception classes
│   ├── utils/
│   │   ├── date_helpers.dart
│   │   └── validators.dart
│   └── database/
│       ├── app_database.dart         # Drift database definition
│       ├── app_database.g.dart       # Generated Drift code
│       ├── tables/                   # Drift table definitions
│       │   ├── logs_table.dart
│       │   ├── intervals_table.dart
│       │   ├── settings_table.dart
│       │   ├── insights_table.dart
│       │   ├── categories_table.dart
│       │   ├── streaks_table.dart
│       │   └── exports_table.dart
│       └── daos/                     # Data Access Objects (Drift DAOs)
│           ├── logs_dao.dart
│           ├── intervals_dao.dart
│           ├── settings_dao.dart
│           ├── insights_dao.dart
│           ├── categories_dao.dart
│           ├── streaks_dao.dart
│           └── exports_dao.dart
│
├── features/                          # Feature modules
│   ├── onboarding/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── onboarding_repository.dart
│   │   │   └── usecases/
│   │   │       └── complete_onboarding.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── onboarding_bloc.dart
│   │       │   ├── onboarding_event.dart
│   │       │   └── onboarding_state.dart
│   │       ├── screens/
│   │       │   ├── welcome_screen.dart
│   │       │   ├── interval_selection_screen.dart
│   │       │   └── permissions_screen.dart
│   │       └── widgets/
│   │           └── onboarding_widgets.dart
│   │
│   ├── logging/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── log_model.dart
│   │   │   └── repositories/
│   │   │       └── log_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── log.dart
│   │   │   ├── repositories/
│   │   │   │   └── log_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_log.dart
│   │   │       ├── get_today_logs.dart
│   │   │       ├── update_log.dart
│   │   │       └── delete_log.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── logging_bloc.dart
│   │       │   ├── logging_event.dart
│   │       │   └── logging_state.dart
│   │       ├── screens/
│   │       │   └── logging_screen.dart
│   │       └── widgets/
│   │           ├── text_input_widget.dart
│   │           └── recent_logs_widget.dart
│   │
│   ├── history/
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── history_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_logs_by_date_range.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── history_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── history_bloc.dart
│   │       │   ├── history_event.dart
│   │       │   └── history_state.dart
│   │       ├── screens/
│   │       │   └── history_screen.dart
│   │       └── widgets/
│   │           ├── log_list_item.dart
│   │           ├── calendar_view.dart
│   │           └── edit_log_modal.dart
│   │
│   ├── insights/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── insight.dart
│   │   │   ├── repositories/
│   │   │   │   └── insight_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_daily_insight.dart
│   │   │       ├── get_top_activities.dart
│   │   │       └── calculate_completion_rate.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── insight_model.dart
│   │   │   └── repositories/
│   │   │       └── insight_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── insights_bloc.dart
│   │       │   ├── insights_event.dart
│   │       │   └── insights_state.dart
│   │       ├── screens/
│   │       │   └── insights_screen.dart
│   │       └── widgets/
│   │           ├── insight_card.dart
│   │           └── charts_widget.dart
│   │
│   ├── settings/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_settings.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_settings.dart
│   │   │       ├── update_interval_duration.dart
│   │   │       └── toggle_notifications.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── settings_model.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── settings_bloc.dart
│   │       │   ├── settings_event.dart
│   │       │   └── settings_state.dart
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           └── settings_widgets.dart
│   │
│   ├── voice/
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── voice_repository.dart
│   │   │   └── usecases/
│   │   │       ├── start_recording.dart
│   │   │       └── transcribe_audio.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── voice_repository_impl.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           └── voice_recorder_widget.dart
│   │
│   ├── categories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       ├── categorize_log.dart
│   │   │       └── initialize_default_categories.dart
│   │   └── data/
│   │       ├── models/
│   │       │   └── category_model.dart
│   │       └── repositories/
│   │           └── category_repository_impl.dart
│   │
│   ├── notifications/
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── notification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── schedule_interval_notification.dart
│   │   │       └── handle_notification_response.dart
│   │   └── data/
│   │       ├── repositories/
│   │       │   └── notification_repository_impl.dart
│   │       └── services/
│   │           └── notification_service.dart
│   │
│   ├── export/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── export_to_csv.dart
│   │   │       └── export_to_json.dart
│   │   └── data/
│   │       └── repositories/
│   │           └── export_repository_impl.dart
│   │
│   └── streaks/
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── streak_repository.dart
│       │   └── usecases/
│       │       └── get_current_streak.dart
│       └── data/
│           └── repositories/
│               └── streak_repository_impl.dart
│
└── shared/                            # Shared widgets & components
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_input.dart
    │   ├── custom_card.dart
    │   ├── loading_spinner.dart
    │   ├── error_view.dart
    │   └── fade_in_view.dart
    └── navigation/
        └── app_router.dart           # go_router configuration
```

---

## Architecture Mapping: React Native → Flutter

### State Management: Zustand → Bloc

**React Native (Zustand):**
```typescript
const useLogsStore = create((set) => ({
  logs: [],
  createLog: async (input) => {
    const log = await logService.createLog(input);
    set((state) => ({ logs: [log, ...state.logs] }));
  }
}));
```

**Flutter (Bloc):**
```dart
// Event
abstract class LoggingEvent {}
class CreateLogEvent extends LoggingEvent {
  final CreateLogInput input;
  CreateLogEvent(this.input);
}

// State
abstract class LoggingState {}
class LoggingLoaded extends LoggingState {
  final List<Log> logs;
  LoggingLoaded(this.logs);
}

// Bloc
class LoggingBloc extends Bloc<LoggingEvent, LoggingState> {
  final CreateLog createLogUseCase;

  LoggingBloc({required this.createLogUseCase}) : super(LoggingInitial()) {
    on<CreateLogEvent>((event, emit) async {
      emit(LoggingLoading());
      final result = await createLogUseCase(event.input);
      result.fold(
        (failure) => emit(LoggingError(failure.message)),
        (log) => emit(LoggingLoaded([log, ...logs])),
      );
    });
  }
}
```

### Database: SQLite (react-native-sqlite-storage) → Drift

**React Native DatabaseService:**
```typescript
class DatabaseService {
  async executeSql(sql: string, params?: any[]): Promise<any[]> {
    const results = await this.db.executeSql(sql, params);
    return results[0].rows.raw();
  }
}
```

**Flutter Drift:**
```dart
// Table definition
class Logs extends Table {
  TextColumn get id => text()();
  IntColumn get timestamp => integer()();
  TextColumn get content => text()();
  TextColumn get entryType => text()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get transcriptionStatus => text().withDefault(const Constant('complete'))();
  TextColumn get category => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get mood => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// DAO
@DriftAccessor(tables: [Logs])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(AppDatabase db) : super(db);

  Future<List<Log>> getTodayLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    return (select(logs)
      ..where((log) => log.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..where((log) => log.isDeleted.equals(0))
      ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
      .get();
  }
}
```

### Services → Repositories + Use Cases

**React Native Service:**
```typescript
class LogService {
  async createLog(input: CreateLogInput): Promise<Log> {
    const log = { ...input, id: uuid(), createdAt: Date.now() };
    await databaseService.executeSql('INSERT INTO logs...', [...]);
    return log;
  }
}
```

**Flutter Repository + Use Case:**
```dart
// Repository Interface (domain layer)
abstract class LogRepository {
  Future<Either<Failure, Log>> createLog(CreateLogInput input);
}

// Repository Implementation (data layer)
class LogRepositoryImpl implements LogRepository {
  final LogsDao logsDao;
  final CategoryRepository categoryRepository;

  LogRepositoryImpl({
    required this.logsDao,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, Log>> createLog(CreateLogInput input) async {
    try {
      // Auto-categorize if enabled
      final category = await categoryRepository.categorizeContent(input.content);

      final logData = LogsCompanion.insert(
        id: const Uuid().v4(),
        timestamp: Value(input.timestamp ?? DateTime.now().millisecondsSinceEpoch),
        content: input.content,
        entryType: input.entryType,
        category: Value(category),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await logsDao.insertLog(logData);
      final log = await logsDao.getLogById(logData.id.value);
      return Right(log.toDomain());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

// Use Case (domain layer)
class CreateLog {
  final LogRepository repository;

  CreateLog(this.repository);

  Future<Either<Failure, Log>> call(CreateLogInput input) {
    return repository.createLog(input);
  }
}
```

---

## Drift Database Schema Implementation

### Core Database File
```dart
// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Logs,
    Intervals,
    Settings,
    Insights,
    Categories,
    Streaks,
    Exports,
  ],
  daos: [
    LogsDao,
    IntervalsDao,
    SettingsDao,
    InsightsDao,
    CategoriesDao,
    StreaksDao,
    ExportsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _insertDefaultSettings();
      await _insertDefaultCategories();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations
    },
  );

  Future<void> _insertDefaultSettings() async {
    // Insert default settings
  }

  Future<void> _insertDefaultCategories() async {
    // Insert default categories: Work, Break, Learning, Social, Distraction
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'interval.db'));
    return NativeDatabase(file);
  });
}
```

### Migration from React Native Schema
All tables match 1:1 with existing schema. See Drift table definitions above for complete mapping.

---

## Notification System Implementation

### Setup flutter_local_notifications
```dart
// lib/features/notifications/data/services/notification_service.dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> scheduleIntervalNotification(int intervalMs) async {
    const androidDetails = AndroidNotificationDetails(
      'interval_channel',
      'Interval Notifications',
      channelDescription: 'Notifications for interval logging',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('text', 'Text'),
        AndroidNotificationAction('voice', 'Voice'),
        AndroidNotificationAction('skip', 'Skip'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      0,
      'What are you doing?',
      'Tap to log your activity',
      tz.TZDateTime.now(tz.local).add(Duration(milliseconds: intervalMs)),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle deep link to logging screen with action
    final action = response.actionId; // 'text', 'voice', or 'skip'
    // Use go_router to navigate
  }
}
```

### Background Notifications (Platform-Specific)
- **Android:** Use WorkManager or AlarmManager for exact scheduling
- **iOS:** Background app refresh limitations - schedule notifications when app is in foreground

---

## Navigation with go_router

```dart
// lib/shared/navigation/app_router.dart
final goRouter = GoRouter(
  initialLocation: '/welcome',
  redirect: (context, state) {
    // Check onboarding status and redirect accordingly
    final settingsBloc = context.read<SettingsBloc>();
    final onboardingCompleted = settingsBloc.state.settings?.onboardingCompleted ?? false;

    if (!onboardingCompleted && !state.matchedLocation.startsWith('/onboarding')) {
      return '/welcome';
    }
    return null;
  },
  routes: [
    // Onboarding
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/interval-selection',
      builder: (context, state) => const IntervalSelectionScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),

    // Main app with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/logging',
          builder: (context, state) => const LoggingScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/insights',
          builder: (context, state) => const InsightsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
```

---

## Voice Recording & Transcription

```dart
// lib/features/voice/data/repositories/voice_repository_impl.dart
import 'package:speech_to_text/speech_to_text.dart';
import 'package:record/record.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final SpeechToText _speechToText = SpeechToText();
  final Record _recorder = Record();

  @override
  Future<Either<Failure, void>> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        await _recorder.start();
        return const Right(null);
      }
      return Left(PermissionFailure('Microphone permission denied'));
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> stopRecordingAndTranscribe() async {
    try {
      final path = await _recorder.stop();
      if (path == null) return Left(VoiceFailure('Recording failed'));

      // For on-device transcription
      bool available = await _speechToText.initialize();
      if (!available) return Left(VoiceFailure('Speech recognition not available'));

      String transcription = '';
      await _speechToText.listen(
        onResult: (result) => transcription = result.recognizedWords,
      );

      return Right(transcription);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }
}
```

---

## Design System (Minimalist Black/White/Grey)

```dart
// lib/core/constants/colors.dart
class AppColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey1 = Color(0xFF1A1A1A);
  static const grey2 = Color(0xFF333333);
  static const grey3 = Color(0xFF666666);
  static const grey4 = Color(0xFF999999);
  static const grey5 = Color(0xFFCCCCCC);
  static const grey6 = Color(0xFFE5E5E5);
  static const grey7 = Color(0xFFF5F5F5);
}

// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: false, // Keep custom minimalist design
    primaryColor: AppColors.black,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.black,
      secondary: AppColors.grey3,
      surface: AppColors.white,
      background: AppColors.white,
      error: AppColors.grey2,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: AppColors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

---

## Dependency Injection Setup

Use `get_it` for service locator pattern:

```dart
// lib/core/di/injection.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton(() => AppDatabase());

  // DAOs
  sl.registerLazySingleton(() => sl<AppDatabase>().logsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().settingsDao);
  // ... other DAOs

  // Repositories
  sl.registerLazySingleton<LogRepository>(
    () => LogRepositoryImpl(
      logsDao: sl(),
      categoryRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateLog(sl()));
  sl.registerLazySingleton(() => GetTodayLogs(sl()));

  // Blocs
  sl.registerFactory(() => LoggingBloc(
    createLog: sl(),
    getTodayLogs: sl(),
  ));

  // Services
  sl.registerLazySingleton(() => NotificationService());
}
```

---

## Implementation Phases

### Phase 1: Project Setup & Core Infrastructure (Week 1)
1. Create Flutter project: `flutter create interval_flutter`
2. Add dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_bloc: ^8.1.3
     bloc: ^8.1.2
     drift: ^2.14.1
     sqlite3_flutter_libs: ^0.5.18
     path_provider: ^2.1.1
     go_router: ^13.0.0
     flutter_local_notifications: ^17.0.0
     timezone: ^0.9.2
     speech_to_text: ^6.6.0
     record: ^5.0.4
     audioplayers: ^5.2.1
     share_plus: ^7.2.1
     fl_chart: ^0.66.0
     uuid: ^4.3.3
     get_it: ^7.6.4
     equatable: ^2.0.5
     dartz: ^0.10.1
     intl: ^0.19.0
     vibration: ^1.8.4

   dev_dependencies:
     drift_dev: ^2.14.1
     build_runner: ^2.4.7
     mockito: ^5.4.4
     bloc_test: ^9.1.5
   ```

3. Setup folder structure as defined above
4. Create `app_database.dart` with Drift configuration
5. Define all table schemas matching React Native database
6. Run `flutter pub run build_runner build` to generate Drift code
7. Setup dependency injection with GetIt
8. Create core constants (colors, text styles, intervals)
9. Define AppTheme with minimalist design

### Phase 2: Domain Layer (Week 1-2)
1. Define all entities (Log, Interval, Settings, Insight, Category, Streak)
2. Create repository interfaces for each domain
3. Implement all use cases:
   - Logging: CreateLog, GetTodayLogs, UpdateLog, DeleteLog
   - Settings: GetSettings, UpdateSettings, SetIntervalDuration
   - Categories: CategorizeLog, InitializeDefaultCategories
   - Insights: GenerateDailyInsight, GetTopActivities, CalculateCompletionRate
   - Intervals: CreateInterval, CompleteInterval, GetCompletionRate
   - Streaks: GetCurrentStreak, UpdateStreak
   - Export: ExportToCSV, ExportToJSON
   - Voice: StartRecording, StopRecording, TranscribeAudio
   - Notifications: ScheduleNotification, HandleNotificationResponse

### Phase 3: Data Layer (Week 2)
1. Implement all DAOs (Drift data access objects)
2. Implement all repository implementations
3. Create data models with `toDomain()` and `fromDomain()` mappers
4. Implement NotificationService with flutter_local_notifications
5. Implement VoiceService with speech_to_text and record packages
6. Test database operations and migrations

### Phase 4: Presentation Layer - Onboarding (Week 2-3)
1. Create OnboardingBloc with events/states
2. Implement WelcomeScreen (minimalist intro)
3. Implement IntervalSelectionScreen (15/30 min selection)
4. Implement PermissionsScreen (request notification permissions)
5. Create shared widgets: CustomButton, FadeInView
6. Setup go_router with onboarding flow

### Phase 5: Presentation Layer - Main App (Week 3-4)
1. **Logging Feature:**
   - Create LoggingBloc
   - Implement LoggingScreen (home screen)
   - Build TextInputWidget (auto-focus, character counter)
   - Build VoiceRecorderWidget
   - Add recent logs preview
   - Integrate haptic feedback

2. **History Feature:**
   - Create HistoryBloc
   - Implement HistoryScreen
   - Build LogListItem widget
   - Add pull-to-refresh
   - Implement calendar view
   - Create EditLogModal

3. **Insights Feature:**
   - Create InsightsBloc
   - Implement InsightsScreen
   - Build InsightCard widgets
   - Implement charts with fl_chart
   - Calculate and display: total logs, completion rate, streak, top activities

4. **Settings Feature:**
   - Create SettingsBloc
   - Implement SettingsScreen
   - Add interval duration toggle
   - Add notification settings
   - Add export functionality

5. **Navigation:**
   - Implement bottom navigation with go_router ShellRoute
   - Setup deep linking for notification actions
   - Handle routing based on onboarding status

### Phase 6: Background Services & Notifications (Week 4)
1. Configure Android WorkManager for background scheduling
2. Setup iOS background app refresh
3. Implement notification scheduling system
4. Add quick action buttons (Text/Voice/Skip)
5. Handle notification tap → deep link to LoggingScreen
6. Test notification reliability on both platforms

### Phase 7: Testing (Week 5)
1. Write unit tests for all use cases
2. Write unit tests for repositories
3. Write bloc tests for all blocs
4. Write widget tests for critical screens
5. Test database migrations
6. Test notification handling
7. Test voice recording/transcription
8. Integration tests for core flows

### Phase 8: Polish & Platform-Specific (Week 5-6)
1. Add loading states and error handling to all screens
2. Implement haptic feedback throughout
3. Add animations (fade-ins, transitions)
4. Configure app icons and splash screen
5. Setup Android-specific configurations (WorkManager, permissions)
6. Setup iOS-specific configurations (background modes, permissions)
7. Test on real devices (iOS and Android)
8. Performance optimization
9. Accessibility improvements

### Phase 9: Data Migration Tool (Optional)
Create a script to migrate existing React Native SQLite data to Flutter:
1. Export data from React Native app (JSON)
2. Import JSON into Flutter Drift database
3. Validate data integrity

---

## Key Implementation Considerations

### 1. Background Notifications
- **Android:** Use `android_alarm_manager_plus` or WorkManager for exact scheduling
- **iOS:** Limited background execution - schedule notifications when app is foregrounded
- Consider using a foreground service on Android for guaranteed delivery

### 2. Voice Transcription
- `speech_to_text` is on-device for iOS (using Apple's Speech framework)
- Android also supports on-device with Google's Speech Recognition
- Privacy-preserving like React Native implementation

### 3. Database Performance
- Drift provides reactive queries with `watchQuery()` for real-time UI updates
- Use indexes on timestamp, category (already defined in schema)
- Batch operations for insights calculation

### 4. State Persistence
- Settings cached with `shared_preferences` for fast access
- Database is source of truth
- Bloc hydration for restoring state

### 5. Deep Linking
- Configure Android `AndroidManifest.xml` with intent filters
- Configure iOS `Info.plist` with URL schemes
- go_router handles deep link routing

### 6. Haptic Feedback
```dart
import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> selection() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 10);
    }
  }

  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }
}
```

---

## Critical Files to Create First

1. `lib/core/database/app_database.dart` - Database foundation
2. `lib/core/database/tables/logs_table.dart` - Primary table
3. `lib/core/constants/colors.dart` - Design system
4. `lib/core/di/injection.dart` - Dependency injection
5. `lib/features/logging/domain/entities/log.dart` - Core entity
6. `lib/features/logging/domain/repositories/log_repository.dart` - Repository interface
7. `lib/features/logging/data/repositories/log_repository_impl.dart` - Repository implementation
8. `lib/shared/navigation/app_router.dart` - Navigation
9. `lib/main.dart` - App entry point

---

## Testing Strategy

```dart
// Example Bloc test
void main() {
  group('LoggingBloc', () {
    late LoggingBloc bloc;
    late MockCreateLog mockCreateLog;

    setUp(() {
      mockCreateLog = MockCreateLog();
      bloc = LoggingBloc(createLog: mockCreateLog);
    });

    blocTest<LoggingBloc, LoggingState>(
      'emits [LoggingLoading, LoggingLoaded] when CreateLogEvent is added',
      build: () {
        when(mockCreateLog(any)).thenAnswer((_) async => Right(tLog));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateLogEvent(tCreateLogInput)),
      expect: () => [
        LoggingLoading(),
        LoggingLoaded([tLog]),
      ],
    );
  });
}
```

## CLAUDE GUIDE FOR BEST PRACTICE

- Use BDD
- Use Best Practices of Coding
- Create abstractions where there's repeatable code
- use Dependency Injection
- depend heavily on code generation packages like mason if needed
- dont use setState anywhere

---

## Migration Checklist

- [ ] Flutter project created with proper folder structure
- [ ] All dependencies added to pubspec.yaml
- [ ] Setup BDD environment for Claude so it remembers to do BDD (TEST ALL Business Logic Behaviors first, then implement UI) also use SOLID principals and CLEAN architecture
- [ ] Drift database configured with all tables
- [ ] All domain entities defined
- [ ] All repository interfaces created
- [ ] All use cases implemented
- [ ] All repository implementations completed
- [ ] All blocs created with events/states
- [ ] Onboarding flow screens implemented
- [ ] Main app screens implemented (Logging, History, Insights, Settings)
- [ ] Bottom navigation with go_router working
- [ ] Notification system configured and tested
- [ ] Voice recording/transcription working
- [ ] Auto-categorization algorithm implemented
- [ ] Insights generation working (stats, charts)
- [ ] Export functionality (CSV/JSON) working
- [ ] Minimalist design system applied throughout
- [ ] Haptic feedback integrated
- [ ] Deep linking from notifications working
- [ ] Background scheduling configured (Android/iOS)
- [ ] All unit tests passing
- [ ] All bloc tests passing
- [ ] Integration tests passing
- [ ] Tested on real Android device
- [ ] Tested on real iOS device
- [ ] App icons and splash screen configured
- [ ] Performance optimized
- [ ] Ready for production build

---

## Expected Timeline

**Total: 5-6 weeks for complete migration**

- Week 1: Setup, core infrastructure, domain layer
- Week 2: Data layer, onboarding UI
- Week 3-4: Main app features (Logging, History, Insights, Settings)
- Week 4: Background services, notifications
- Week 5: Testing, polish
- Week 6: Platform-specific optimizations, final testing

---

## Advantages of Flutter Migration

1. **Better Performance:** Dart compiles to native code, faster than React Native's JS bridge
2. **Type Safety:** Drift provides compile-time type safety for database queries
3. **Predictable State:** Bloc pattern is more structured than Zustand for complex apps
4. **Better Tooling:** Flutter DevTools, Drift inspector, excellent IDE support
5. **Single Codebase:** Truly shared UI code (React Native still has platform-specific components)
6. **Mature Ecosystem:** flutter_local_notifications is more stable than Notifee
7. **Hot Reload:** Flutter's hot reload is faster and more reliable

---

## Next Steps

1. Review this plan and confirm approach
2. Create Flutter project structure
3. Begin Phase 1: Core infrastructure setup
4. Implement database layer with Drift
5. Build out domain and data layers
6. Start with onboarding screens
7. Progress through main features systematically
