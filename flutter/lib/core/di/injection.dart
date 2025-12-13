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
import '../../features/logging/presentation/bloc/logging_bloc.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/insights/presentation/bloc/insights_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/streaks/presentation/bloc/streaks_bloc.dart';
import '../../features/export/presentation/bloc/export_bloc.dart';
import '../../features/categories/presentation/bloc/categories_bloc.dart';
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
import '../../features/voice/data/repositories/voice_repository_impl.dart';
import '../../features/voice/domain/repositories/voice_repository.dart';
import '../../features/voice/presentation/bloc/voice_bloc.dart';

import '../../features/settings/domain/usecases/toggle_voice.dart';
import '../../features/settings/domain/usecases/toggle_auto_categorize.dart';

// Use Case Imports
import '../../features/categories/domain/usecases/get_all_categories.dart';
import '../../features/categories/domain/usecases/create_category.dart';
import '../../features/categories/domain/usecases/update_category.dart';
import '../../features/categories/domain/usecases/delete_category.dart';
import '../../features/categories/domain/usecases/categorize_log.dart';

import '../../features/insights/domain/usecases/generate_daily_insight.dart';
import '../../features/insights/domain/usecases/get_top_activities.dart';
import '../../features/insights/domain/usecases/calculate_completion_rate.dart';

import '../../features/streaks/domain/usecases/get_current_streak.dart';
import '../../features/streaks/domain/usecases/update_streak.dart';

import '../../features/export/domain/usecases/export_to_csv.dart';
import '../../features/export/domain/usecases/export_to_json.dart';

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
  sl.registerLazySingleton(() => ToggleVoiceUseCase(sl()));
  sl.registerLazySingleton(() => ToggleAutoCategorizeUseCase(sl()));

  // Categories Use Cases
  sl.registerLazySingleton(() => GetAllCategories(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => CategorizeLog(sl()));

  // Insights Use Cases
  sl.registerLazySingleton(() => GenerateDailyInsight(sl()));
  sl.registerLazySingleton(() => GetTopActivities(sl()));
  sl.registerLazySingleton(() => CalculateCompletionRate(sl()));

  // Streaks Use Cases
  sl.registerLazySingleton(() => GetCurrentStreak(sl()));
  sl.registerLazySingleton(() => UpdateStreak(sl()));

  // Export Use Cases
  sl.registerLazySingleton(() => ExportToCSV(sl()));
  sl.registerLazySingleton(() => ExportToJSON(sl()));

  // ============== BLOCS ==============
  // Registered as factories so each screen gets a new instance
  sl.registerFactory(() => LoggingBloc(
        createLog: sl(),
        getTodayLogs: sl(),
        updateLog: sl(),
        deleteLog: sl(),
        searchLogs: sl(),
      ));

  sl.registerFactory(() => HistoryBloc(
        getLogsByDateRange: sl(),
        searchLogs: sl(),
      ));

  sl.registerFactory(() => InsightsBloc(
        generateDailyInsight: sl(),
        getTopActivities: sl(),
        calculateCompletionRate: sl(),
      ));

  sl.registerFactory(() => SettingsBloc(
        getAppSettings: sl(),
        updateIntervalDuration: sl(),
        toggleNotifications: sl(),
        completeOnboarding: sl(),
        toggleVoice: sl(),
        toggleAutoCategorize: sl(),
      ));

  sl.registerFactory(() => StreaksBloc(
        getCurrentStreak: sl(),
      ));

  sl.registerFactory(() => ExportBloc(
        exportToCSV: sl(),
        exportToJSON: sl(),
      ));

  sl.registerFactory(() => CategoriesBloc(
        getAllCategories: sl(),
        createCategory: sl(),
        updateCategory: sl(),
        deleteCategory: sl(),
      ));

  sl.registerFactory(() => VoiceBloc(
        sl(),
      ));

  // Singleton instance
  sl.registerLazySingleton<VoiceRepository>(
    () => VoiceRepositoryImpl(),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}
