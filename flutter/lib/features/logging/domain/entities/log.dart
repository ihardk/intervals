import 'package:freezed_annotation/freezed_annotation.dart';

part 'log.freezed.dart';

/// Entry type enumeration
enum EntryType {
  @JsonValue('text')
  text,
  @JsonValue('voice')
  voice,
  @JsonValue('manual')
  manual,
  @JsonValue('skipped')
  skipped,
}

/// Transcription status enumeration
enum TranscriptionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('complete')
  complete,
  @JsonValue('failed')
  failed,
}

/// Log entity - represents a user activity log entry
/// All timestamps are in milliseconds (Unix epoch)
@freezed
class Log with _$Log {
  const factory Log({
    required String id, // UUID v4
    required int
        timestamp, // Unix timestamp in milliseconds (when activity happened)
    required String content, // Log text content
    required EntryType entryType, // How it was created
    String? audioPath, // Path to audio file if voice entry
    @Default(TranscriptionStatus.complete)
    TranscriptionStatus transcriptionStatus,
    String? category, // Auto or manual category
    @Default([]) List<String> tags, // Flexible tags
    String? mood, // Optional mood
    required int createdAt, // Creation timestamp in milliseconds
    required int updatedAt, // Last update timestamp in milliseconds
    @Default(false) bool isDeleted, // Soft delete flag
    Map<String, dynamic>? metadata, // Extensible field for future use
  }) = _Log;

  const Log._();

  /// Check if this is a voice log
  bool get isVoice => entryType == EntryType.voice;

  /// Check if this is a text log
  bool get isText => entryType == EntryType.text;

  /// Check if transcription is pending
  bool get isTranscriptionPending =>
      transcriptionStatus == TranscriptionStatus.pending;

  /// Check if log was created today
  bool get isToday {
    final now = DateTime.now();
    final logDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return logDate.year == now.year &&
        logDate.month == now.month &&
        logDate.day == now.day;
  }
}

/// Input for creating a new log
@freezed
class CreateLogInput with _$CreateLogInput {
  const factory CreateLogInput({
    required String content,
    required EntryType entryType,
    String? audioPath,
    int? timestamp, // Defaults to now if not provided
    String? category,
    @Default([]) List<String> tags,
    String? mood,
  }) = _CreateLogInput;
}

/// Input for updating an existing log
@freezed
class UpdateLogInput with _$UpdateLogInput {
  const factory UpdateLogInput({
    required String id,
    String? content,
    String? category,
    List<String>? tags,
    String? mood,
  }) = _UpdateLogInput;
}
