import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_streak.dart';
import 'streaks_event.dart';
import 'streaks_state.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  final GetCurrentStreak getCurrentStreak;

  StreaksBloc({
    required this.getCurrentStreak,
  }) : super(const StreaksState.initial()) {
    on<LoadStreak>(_onLoadStreak);
  }

  Future<void> _onLoadStreak(
    LoadStreak event,
    Emitter<StreaksState> emit,
  ) async {
    emit(const StreaksState.loading());
    final result = await getCurrentStreak(event.type);
    emit(result.fold(
      (failure) => StreaksState.error(failure.message),
      (count) => StreaksState.loaded(count),
    ));
  }
}
