import 'package:freezed_annotation/freezed_annotation.dart';

/// Notification action types for quick actions
enum NotificationAction {
  @JsonValue('text')
  text,
  @JsonValue('voice')
  voice,
  @JsonValue('skip')
  skip,
}

/// Extension for NotificationAction
extension NotificationActionExtension on NotificationAction {
  String get label {
    switch (this) {
      case NotificationAction.text:
        return 'Text';
      case NotificationAction.voice:
        return 'Voice';
      case NotificationAction.skip:
        return 'Skip';
    }
  }

  String get actionId {
    switch (this) {
      case NotificationAction.text:
        return 'text';
      case NotificationAction.voice:
        return 'voice';
      case NotificationAction.skip:
        return 'skip';
    }
  }
}
