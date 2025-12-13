import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/insight.dart';
import '../../domain/usecases/generate_daily_insight.dart';
import '../../domain/usecases/get_top_activities.dart';
import '../../domain/usecases/calculate_completion_rate.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final GenerateDailyInsight generateDailyInsight;
  final GetTopActivities getTopActivities;
  final CalculateCompletionRate calculateCompletionRate;

  InsightsBloc({
    required this.generateDailyInsight,
    required this.getTopActivities,
    required this.calculateCompletionRate,
  }) : super(const InsightsState.initial()) {
    on<LoadInsights>(_onLoadInsights);
    on<RefreshInsights>(_onLoadInsights);
  }

  Future<void> _onLoadInsights(
    InsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(const InsightsState.loading());

    final date = event.map(
      loadInsights: (e) => e.date ?? DateTime.now(),
      refreshInsights: (_) => DateTime.now(),
    );

    final results = await Future.wait([
      generateDailyInsight(date),
      getTopActivities(date),
      calculateCompletionRate(date),
    ]);

    final insightResult = results[0] as Either<Failure, Insight>;
    final topActivitiesResult =
        results[1] as Either<Failure, List<ActivityCount>>;
    final completionRateResult = results[2] as Either<Failure, double>;

    if (insightResult.isLeft()) {
      return emit(InsightsState.error(
        insightResult.fold((l) => l.message, (r) => ''),
      ));
    }

    if (topActivitiesResult.isLeft()) {
      return emit(InsightsState.error(
        topActivitiesResult.fold((l) => l.message, (r) => ''),
      ));
    }

    if (completionRateResult.isLeft()) {
      // For completion rate failure, we might want to just show 0?
      // But for now let's fail the whole state as per test expectation.
      return emit(InsightsState.error(
        completionRateResult.fold((l) => l.message, (r) => ''),
      ));
    }

    emit(InsightsState.loaded(
      dailyInsight: insightResult.fold((l) => throw l, (r) => r),
      topActivities: topActivitiesResult.fold((l) => throw l, (r) => r),
      completionRate: completionRateResult.fold((l) => throw l, (r) => r),
    ));
  }
}
