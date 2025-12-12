/**
 * Notification Service - Handle local notifications and scheduling
 * Note: This uses @notifee/react-native for advanced notification features
 */

import notifee, { AndroidImportance, TriggerType, TimestampTrigger } from '@notifee/react-native';
import { NOTIFICATION_CHANNEL_ID, NOTIFICATION_CHANNEL_NAME, NOTIFICATION_MESSAGES, NOTIFICATION_ACTIONS } from '../../constants/notifications';

export interface NotificationResponse {
  notificationId: string;
  actionId?: string;
  timestamp: number;
}

export interface INotificationService {
  requestPermissions(): Promise<boolean>;
  hasPermissions(): Promise<boolean>;
  scheduleIntervalNotification(intervalMs: number): Promise<string>;
  cancelNotification(notificationId: string): Promise<void>;
  cancelAllNotifications(): Promise<void>;
  showNotification(title: string, body: string): Promise<void>;
}

class NotificationService implements INotificationService {
  private channelId = NOTIFICATION_CHANNEL_ID;

  async initialize(): Promise<void> {
    // Create notification channel for Android
    await notifee.createChannel({
      id: this.channelId,
      name: NOTIFICATION_CHANNEL_NAME,
      importance: AndroidImportance.HIGH,
      sound: 'default',
    });
  }

  async requestPermissions(): Promise<boolean> {
    const settings = await notifee.requestPermission();
    return settings.authorizationStatus >= 1; // 1 = authorized
  }

  async hasPermissions(): Promise<boolean> {
    const settings = await notifee.getNotificationSettings();
    return settings.authorizationStatus >= 1;
  }

  async scheduleIntervalNotification(intervalMs: number): Promise<string> {
    // Get random message
    const randomMessage =
      NOTIFICATION_MESSAGES[Math.floor(Math.random() * NOTIFICATION_MESSAGES.length)];

    // Calculate trigger time
    const triggerTime = Date.now() + intervalMs;
    const trigger: TimestampTrigger = {
      type: TriggerType.TIMESTAMP,
      timestamp: triggerTime,
    };

    // Create notification
    const notificationId = await notifee.createTriggerNotification(
      {
        title: 'Interval',
        body: randomMessage,
        android: {
          channelId: this.channelId,
          importance: AndroidImportance.HIGH,
          pressAction: {
            id: 'default',
            launchActivity: 'default',
          },
          actions: [
            {
              title: 'Text Log',
              pressAction: {
                id: NOTIFICATION_ACTIONS.TEXT,
              },
            },
            {
              title: 'Voice Log',
              pressAction: {
                id: NOTIFICATION_ACTIONS.VOICE,
              },
            },
            {
              title: 'Skip',
              pressAction: {
                id: NOTIFICATION_ACTIONS.SKIP,
              },
            },
          ],
        },
        ios: {
          categoryId: 'interval-actions',
          foregroundPresentationOptions: {
            alert: true,
            badge: true,
            sound: true,
          },
        },
      },
      trigger
    );

    return notificationId;
  }

  async cancelNotification(notificationId: string): Promise<void> {
    await notifee.cancelNotification(notificationId);
  }

  async cancelAllNotifications(): Promise<void> {
    await notifee.cancelAllNotifications();
  }

  async showNotification(title: string, body: string): Promise<void> {
    await notifee.displayNotification({
      title,
      body,
      android: {
        channelId: this.channelId,
        importance: AndroidImportance.HIGH,
      },
    });
  }

  async getPendingNotifications(): Promise<any[]> {
    const notifications = await notifee.getTriggerNotifications();
    return notifications;
  }
}

export const notificationService = new NotificationService();
