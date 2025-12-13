import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/voice_repository.dart';
import 'voice_event.dart';
import 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final VoiceRepository _repository;

  VoiceBloc(this._repository) : super(const VoiceState.initial()) {
    on<Initialize>(_onInitialize);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<ProcessResult>(_onProcessResult);
  }

  Future<void> _onInitialize(
    Initialize event,
    Emitter<VoiceState> emit,
  ) async {
    final result = await _repository.initialize();
    result.fold(
      (failure) => emit(VoiceState.failure(failure.message)),
      (_) {}, // initialized
    );
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceState> emit,
  ) async {
    // If not initialized, initialize first
    if (!_repository.isListening) {
      final initResult = await _repository.initialize();
      bool initFailed = false;
      initResult.fold(
        (failure) {
          emit(VoiceState.failure(failure.message));
          initFailed = true;
        },
        (_) {},
      );
      if (initFailed) return;
    }

    emit(const VoiceState.listening(partialResult: ''));

    final result = await _repository.startListening(
      onResult: (text) {
        // We can emit intermediate states here if we want to show live transcription
        // For now, let's just update the listening state with partial results
        // Since we are not in the bloc main loop, we can't emit directly safely without checking isClosed
        // But since this is a callback, we might need a separate event to update state from inside callback
        if (!isClosed) {
          add(VoiceEvent.processResult(text));
        }
      },
    );

    result.fold(
      (failure) => emit(VoiceState.failure(failure.message)),
      (_) {}, // Started successfully
    );
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceState> emit,
  ) async {
    await _repository.stopListening();
    // When stopping, we might want to carry over the last partial result as success
    state.maybeMap(
      listening: (state) {
        if (state.partialResult.isNotEmpty) {
          emit(VoiceState.success(state.partialResult));
        } else {
          emit(const VoiceState.initial());
        }
      },
      orElse: () {},
    );
  }

  Future<void> _onProcessResult(
    ProcessResult event,
    Emitter<VoiceState> emit,
  ) async {
    emit(VoiceState.listening(partialResult: event.text));
  }
}
