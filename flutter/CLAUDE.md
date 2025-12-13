# CLAUDE.md - Flutter

This file provides guidance to Claude Code (claude.ai/code) when working with the Flutter version of the Interval app in this repository.

## Project Overview

**Interval Flutter** is a minimalist awareness & productivity logger built with Flutter. This is a migration from the React Native version (in `/react-native`).

**Tech Stack:**
- Flutter SDK 3.22.2+
- Dart 3.4.3+
- State Management: Bloc (flutter_bloc)
- Database: Drift (type-safe SQL with code generation)
- Notifications: flutter_local_notifications
- Navigation: go_router
- Voice: speech_to_text, record packages
- Code Generation: freezed, json_serializable, drift_dev

## Development Commands

### Running the App
```bash
cd flutter
flutter run                   # Run on connected device/emulator
flutter run -d chrome         # Run on Chrome (web)
flutter run -d macos          # Run on macOS
flutter devices               # List available devices
```

### Code Generation
```bash
flutter pub run build_runner build                    # Generate code once
flutter pub run build_runner build --delete-conflicting-outputs  # Force rebuild
flutter pub run build_runner watch                    # Watch for changes
```

### Testing & Quality
```bash
flutter test                  # Run all tests
flutter test --coverage       # Run with coverage
flutter analyze               # Run static analysis
dart format lib/              # Format code
```

### Building
```bash
flutter build apk             # Build Android APK
flutter build appbundle       # Build Android App Bundle
flutter build ios             # Build iOS (requires macOS)
flutter build web             # Build for web
```

## Architecture Overview

### Clean Architecture + BDD

The app follows **Clean Architecture** with **Behavior-Driven Development (BDD)** principles:

```
lib/
├── core/                    # Shared utilities, theme, database
│   ├── constants/          # colors, text_styles, intervals, app_constants
│   ├── theme/              # app_theme.dart
│   ├── errors/             # failures.dart, exceptions.dart
│   ├── utils/              # date_helpers.dart, validators.dart
│   └── database/           # Drift database, tables, DAOs
├── features/               # Feature modules (clean architecture)
│   └── [feature_name]/
│       ├── domain/        # Business logic (pure Dart)
│       │   ├── entities/  # Domain models (freezed)
│       │   ├── repositories/  # Repository interfaces
│       │   └── usecases/  # Business use cases
│       ├── data/          # Data layer
│       │   ├── models/    # Data models (freezed + json)
│       │   └── repositories/  # Repository implementations
│       └── presentation/  # UI layer
│           ├── bloc/      # Bloc (events, states, bloc)
│           ├── screens/   # Screen widgets
│           └── widgets/   # Feature-specific widgets
└── shared/                 # Shared UI components
    ├── widgets/           # Reusable widgets
    └── navigation/        # go_router configuration
```

### Key Architectural Patterns

**1. Clean Architecture Layers:**
- **Domain Layer (Pure Dart):** Entities, repositories (interfaces), use cases
- **Data Layer:** Repository implementations, data models, data sources
- **Presentation Layer:** Bloc, Screens, Widgets

**2. Code Generation:**
- **Freezed:** Immutable data classes with copyWith, equality, toString
- **Drift:** Type-safe SQL queries, DAOs, database schema
- **JSON Serializable:** JSON serialization for API/export (future)

**3. State Management (Bloc Pattern):**
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

  on<CreateLogEvent>((event, emit) async {
    final result = await createLogUseCase(event.input);
    result.fold(
      (failure) => emit(LoggingError(failure.message)),
      (log) => emit(LoggingLoaded([log, ...logs])),
    );
  });
}
```

**4. Error Handling (Either Pattern):**
Using `dartz` package for functional error handling:
```dart
Future<Either<Failure, Log>> createLog(CreateLogInput input);

// Usage
final result = await repository.createLog(input);
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (log) => print('Success: ${log.content}'),
);
```

**5. Dependency Injection (GetIt):**
```dart
// Setup in core/di/injection.dart
final sl = GetIt.instance;

sl.registerLazySingleton(() => AppDatabase());
sl.registerLazySingleton<LogRepository>(() => LogRepositoryImpl(db: sl()));
sl.registerLazySingleton(() => CreateLog(sl()));
sl.registerFactory(() => LoggingBloc(createLog: sl()));
```

## Database Schema (Drift)

All tables match the React Native SQLite schema exactly:

- **logs** - User activity entries (id, timestamp, content, entry_type, category, etc.)
- **intervals** - Notification intervals and user responses
- **settings** - Key-value app settings
- **insights** - Pre-computed analytics (cached)
- **categories** - Category definitions with keywords for auto-categorization
- **streaks** - User consistency tracking
- **exports** - Export history

### Key Drift Concepts

**Table Definition:**
```dart
@DataClassName('LogData')
class Logs extends Table {
  TextColumn get id => text()();
  IntColumn get timestamp => integer()();
  TextColumn get content => text()();
  // ...

  @override
  Set<Column> get primaryKey => {id};
}
```

**DAO (Data Access Object):**
```dart
@DriftAccessor(tables: [Logs])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  Future<List<LogData>> getTodayLogs() {
    return (select(logs)
      ..where((log) => log.timestamp.isBetweenValues(start, end))
      ..orderBy([(log) => OrderingTerm.desc(log.timestamp)]))
      .get();
  }
}
```

## Freezed Data Classes

All entities and models use Freezed for immutability:

```dart
@freezed
class Log with _$Log {
  const factory Log({
    required String id,
    required int timestamp,
    required String content,
    required EntryType entryType,
    // ...
  }) = _Log;

  const Log._();

  // Computed properties
  bool get isToday { /* ... */ }
}
```

Run code generation after changes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## BDD Development Workflow

**IMPORTANT:** Always test business logic first (TDD/BDD), then implement UI.

1. **Write Use Case Test** (BDD)
   ```dart
   // test/features/logging/domain/usecases/create_log_test.dart
   test('should create log with auto-categorization', () async {
     when(mockRepository.createLog(any)).thenAnswer((_) async => Right(tLog));

     final result = await usecase(tInput);

     expect(result, Right(tLog));
     verify(mockRepository.createLog(tInput));
   });
   ```

2. **Implement Use Case**
   ```dart
   class CreateLog {
     final LogRepository repository;

     Future<Either<Failure, Log>> call(CreateLogInput input) {
       return repository.createLog(input);
     }
   }
   ```

3. **Write Repository Test**
4. **Implement Repository**
5. **Write Bloc Test** (bloc_test package)
6. **Implement Bloc**
7. **Implement UI**

## Design System

**Minimalist Black/White/Grey:**
- All colors defined in `lib/core/constants/colors.dart`
- Typography in `lib/core/constants/text_styles.dart`
- Theme in `lib/core/theme/app_theme.dart`
- NO Material Design 3 - custom minimalist design only

**Key Design Principles:**
- High contrast (black text on white, white text on black)
- Sans-serif typography with clear hierarchy
- Zero elevation (flat design)
- Minimal color (only for categories in insights)
- Maximum whitespace (>50%)
- Fast interactions (<300ms)

## Common Development Patterns

### Creating a New Feature

1. **Create folder structure:**
   ```
   lib/features/new_feature/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── data/
   │   ├── models/
   │   └── repositories/
   └── presentation/
       ├── bloc/
       ├── screens/
       └── widgets/
   ```

2. **Define entity (freezed):**
   ```dart
   @freezed
   class MyEntity with _$MyEntity {
     const factory MyEntity({required String id}) = _MyEntity;
   }
   ```

3. **Define repository interface:**
   ```dart
   abstract class MyRepository {
     Future<Either<Failure, MyEntity>> getEntity(String id);
   }
   ```

4. **Create use case:**
   ```dart
   class GetEntity {
     final MyRepository repository;
     Future<Either<Failure, MyEntity>> call(String id) => repository.getEntity(id);
   }
   ```

5. **Write tests (BDD)**
6. **Implement repository**
7. **Create Bloc**
8. **Build UI**

### Adding a New Database Table

1. Create table in `lib/core/database/tables/`
2. Add table to `@DriftDatabase` annotation in `app_database.dart`
3. Create DAO if needed
4. Run `flutter pub run build_runner build`
5. Update migration in `app_database.dart` if schema version changes

### Navigation with go_router

```dart
// In app_router.dart
GoRoute(
  path: '/logging',
  builder: (context, state) => const LoggingScreen(),
),

// Navigate
context.go('/logging');

// Navigate with parameters
context.go('/log/${logId}');

// Deep link from notification
final uri = Uri.parse('interval://logging?mode=voice');
// go_router handles the routing
```

## Testing

### Unit Tests (Use Cases, Repositories)
```bash
flutter test test/features/logging/domain/usecases/
```

### Bloc Tests
```dart
blocTest<LoggingBloc, LoggingState>(
  'emits [LoggingLoading, LoggingLoaded] when CreateLogEvent is added',
  build: () {
    when(mockCreateLog(any)).thenAnswer((_) async => Right(tLog));
    return bloc;
  },
  act: (bloc) => bloc.add(CreateLogEvent(tInput)),
  expect: () => [LoggingLoading(), LoggingLoaded([tLog])],
);
```

### Widget Tests
```dart
testWidgets('should display log content', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LogListItem(log: tLog)));
  expect(find.text(tLog.content), findsOneWidget);
});
```

## Important Files to Reference

- **DATABASE_SCHEMA.md** - Complete database schema documentation
- **ARCHITECTURE.md** - React Native architecture (reference for features)
- **API_SPECIFICATIONS.md** - Data models and interfaces
- **pubspec.yaml** - Dependencies

## Code Generation Commands

After modifying:
- Freezed classes (entities, models)
- Drift tables or DAOs
- JSON serializable classes

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or watch for changes:
```bash
flutter pub run build_runner watch
```

## Migration from React Native

**Completed:**
- ✅ Project structure with clean architecture
- ✅ Core constants (colors, text styles, intervals, app constants)
- ✅ Theme (minimalist black/white/grey)
- ✅ Error handling (failures, exceptions)
- ✅ Database schema (all 7 tables with Drift)
- ✅ Log entity with Freezed
- ✅ Code generation setup (freezed, drift, json_serializable)

**Next Steps:**
1. Create all domain entities (Interval, Settings, Insight, Category, Streak)
2. Define repository interfaces
3. Implement use cases (BDD tests first!)
4. Create DAOs for database operations
5. Implement repository implementations
6. Create Blocs for each feature
7. Build UI screens and widgets
8. Setup notifications
9. Implement voice recording/transcription
10. Add navigation with go_router

## Best Practices

1. **Always use freezed for data classes** - immutability, copyWith, equality
2. **Never use setState** - use Bloc for all state management
3. **Test business logic first** (BDD/TDD) - then implement UI
4. **Use dependency injection** (GetIt) - testability and loose coupling
5. **Code generation for boilerplate** - freezed, drift, json_serializable
6. **SOLID principles** - especially Single Responsibility and Dependency Inversion
7. **Either pattern for errors** - functional error handling with dartz
8. **Parameterized queries** - always use Drift's type-safe query builders

## Version

**App Version:** 1.0.0-alpha
**Flutter SDK:** 3.22.2+
**Dart SDK:** 3.4.3+
**Last Updated:** 2025-12-13

## Key Differences from React Native Version

1. **State Management:** Zustand → Bloc (more structured, event-driven)
2. **Database:** SQLite wrapper → Drift (type-safe, code generation)
3. **Data Classes:** Plain interfaces → Freezed (immutable, code generation)
4. **Error Handling:** Try/catch → Either pattern (functional, type-safe)
5. **Architecture:** Layered services → Clean Architecture (domain/data/presentation)
6. **Navigation:** React Navigation → go_router (declarative, type-safe)
