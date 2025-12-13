import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/voice_repository.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final SpeechToText _speechToText;
  bool _isInitialized = false;

  VoiceRepositoryImpl({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      // Check permissions first
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          return const Left(PermissionFailure('Microphone permission denied'));
        }
      }

      if (!_isInitialized) {
        _isInitialized = await _speechToText.initialize();
      }

      return Right(_isInitialized);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> startListening({
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      final initResult = await initialize();
      if (initResult.isLeft()) {
        return initResult.map((_) {});
      }
    }

    try {
      if (_speechToText.isNotListening) {
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult || result.recognizedWords.isNotEmpty) {
              onResult(result.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
            listenMode: ListenMode.dictation,
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await _speechToText.stop();
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }
}
