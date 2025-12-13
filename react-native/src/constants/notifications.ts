/**
 * Notification constants and messages
 */

export const NOTIFICATION_CHANNEL_ID = 'interval-reminders';
export const NOTIFICATION_CHANNEL_NAME = 'Interval Reminders';

export const NOTIFICATION_MESSAGES = [
  'What are you doing now?',
  'Take a moment to log this moment.',
  'Quick check-in.',
  'Time for awareness.',
  'What\'s happening?',
  'Log your current activity.',
] as const;

export const NOTIFICATION_ACTIONS = {
  TEXT: 'text_log',
  VOICE: 'voice_log',
  SKIP: 'skip',
} as const;

export const NOTIFICATION_ACTION_TITLES = {
  [NOTIFICATION_ACTIONS.TEXT]: 'Text Log',
  [NOTIFICATION_ACTIONS.VOICE]: 'Voice Log',
  [NOTIFICATION_ACTIONS.SKIP]: 'Skip',
} as const;
