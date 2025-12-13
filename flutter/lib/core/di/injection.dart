import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/logging/data/repositories/log_repository_impl.dart';
import '../../features/logging/data/repositories/interval_repository_impl.dart';
import '../../features/logging/domain/repositories/log_repository.dart';
import '../../features/logging/domain/repositories/interval_repository.dart';
import '../../features/logging/domain/usecases/create_log.dart';
import '../../features/logging/domain/usecases/get_today_logs.dart';
import '../../features/logging/domain/usecases/update_log.dart';
import '../../features/logging/domain/usecases/delete_log.dart';
import '../../features/logging/domain/usecases/get_logs_by_date_range.dart';
import '../../features/logging/domain/usecases/search_logs.dart';
import '../../features/logging/domain/usecases/create_interval.dart';
import '../../features/logging/domain/usecases/complete_interval.dart';
import '../../features/logging/domain/usecases/get_today_completion_rate.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_app_settings.dart';
import '../../features/settings/domain/usecases/update_interval_duration.dart';
import '../../features/settings/domain/usecases/toggle_notifications.dart';
import '../../features/settings/domain/usecases/complete_onboarding.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/insights/data/repositories/insight_repository_impl.dart';
import '../../features/insights/domain/repositories/insight_repository.dart';
import '../../features/streaks/data/repositories/streak_repository_impl.dart';
import '../../features/streaks/domain/repositories/streak_repository.dart';
import '../../features/export/data/repositories/export_repository_impl.dart';
import '../../features/export/domain/repositories/export_repository.dart';

/// Service Locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this once at app startup before runApp()
Future<void> init() async {
  // ============== DATABASE ==============
  // Singleton - single instance for entire app
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ============== DAOs ==============
  // Access DAOs from database instance
  sl.registerLazySingleton(() => sl<AppDatabase>().logsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().intervalsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().settingsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().categoriesDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().insightsDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().streaksDao);
  sl.registerLazySingleton(() => sl<AppDatabase>().exportsDao);

  // ============== REPOSITORIES ==============
  // Singleton instances
  sl.registerLazySingleton<LogRepository>(
    () => LogRepositoryImpl(
      logsDao: sl(),
      categoriesDao: sl(),
    ),
  );

  sl.registerLazySingleton<IntervalRepository>(
    () => IntervalRepositoryImpl(
      intervalsDao: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      settingsDao: sl(),
    ),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      categoriesDao: sl(),
    ),
  );

  sl.registerLazySingleton<InsightRepository>(
    () => InsightRepositoryImpl(
      insightsDao: sl(),
      logsDao: sl(),
    ),
  );

  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(
      streaksDao: sl(),
    ),
  );

  sl.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(
      exportsDao: sl(),
      logsDao: sl(),
    ),
  );

  // ============== USE CASES ==============
  // Logging Use Cases
  sl.registerLazySingleton(() => CreateLog(sl()));
  sl.registerLazySingleton(() => GetTodayLogs(sl()));
  sl.registerLazySingleton(() => UpdateLog(sl()));
  sl.registerLazySingleton(() => DeleteLog(sl()));
  sl.registerLazySingleton(() => GetLogsByDateRange(sl()));
  sl.registerLazySingleton(() => SearchLogs(sl()));

  // Interval Use Cases
  sl.registerLazySingleton(() => CreateInterval(sl()));
  sl.registerLazySingleton(() => CompleteInterval(sl()));
  sl.registerLazySingleton(() => GetTodayCompletionRate(sl()));

  // Settings Use Cases
  sl.registerLazySingleton(() => GetAppSettings(sl()));
  sl.registerLazySingleton(() => UpdateIntervalDuration(sl()));
  sl.registerLazySingleton(() => ToggleNotifications(sl()));
  sl.registerLazySingleton(() => CompleteOnboarding(sl()));

  // ============== BLOCS ==============
  // Registered as factories so each screen gets a new instance
  // TODO: Register Blocs when they're created
  // sl.registerFactory(() => LoggingBloc(
  //   createLog: sl(),
  //   getTodayLogs: sl(),
  //   updateLog: sl(),
  //   deleteLog: sl(),
  // ));

  // TODO: Add more Bloc registrations as they're created
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
