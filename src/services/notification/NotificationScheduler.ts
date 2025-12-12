/**
 * Notification Scheduler - Handles background notification scheduling
 */

import { notificationService } from './NotificationService';
import { intervalService } from '../intervals/IntervalService';
import { settingsService } from '../settings/SettingsService';
import { navigate } from '../../navigation/NavigationService';

class NotificationScheduler {
  private currentNotificationId: string | null = null;
  private isScheduling = false;

  /**
   * Start the notification scheduler
   */
  async start(): Promise<void> {
    if (this.isScheduling) {
      console.log('Scheduler already running');
      return;
    }

    try {
      this.isScheduling = true;

      // Check if notifications are enabled
      const settings = await settingsService.getSettings();
      if (!settings.notificationsEnabled) {
        console.log('Notifications disabled in settings');
        return;
      }

      // Check permissions
      const hasPermissions = await notificationService.hasPermissions();
      if (!hasPermissions) {
        console.log('No notification permissions');
        return;
      }

      // Schedule next notification
      await this.scheduleNext();
    } catch (error) {
      console.error('Failed to start notification scheduler:', error);
      this.isScheduling = false;
    }
  }

  /**
   * Stop the notification scheduler
   */
  async stop(): Promise<void> {
    this.isScheduling = false;

    if (this.currentNotificationId) {
      await notificationService.cancelNotification(this.currentNotificationId);
      this.currentNotificationId = null;
    }

    console.log('Notification scheduler stopped');
  }

  /**
   * Schedule the next interval notification
   */
  async scheduleNext(): Promise<void> {
    try {
      const intervalDuration = await settingsService.getSetting<number>('intervalDuration');

      // Create interval record in database
      const scheduledTime = Date.now() + intervalDuration;
      const interval = await intervalService.createInterval({
        scheduledTime,
        intervalDuration,
      });

      // Schedule the notification
      const notificationId = await notificationService.scheduleIntervalNotification(
        intervalDuration
      );

      this.currentNotificationId = notificationId;

      console.log(`Next notification scheduled in ${intervalDuration / 60000} minutes`);
      console.log(`Interval ID: ${interval.id}, Notification ID: ${notificationId}`);
    } catch (error) {
      console.error('Failed to schedule next notification:', error);
    }
  }

  /**
   * Handle notification response (user tapped notification)
   */
  async handleNotificationResponse(
    notificationId: string,
    actionId?: string
  ): Promise<void> {
    try {
      const now = Date.now();

      // Find the interval for this notification
      const intervals = await intervalService.getIntervalsByDateRange(
        new Date(now - 60 * 60 * 1000), // 1 hour ago
        new Date(now)
      );

      const interval = intervals.find((i) => !i.isCompleted);

      if (interval) {
        if (actionId === 'skip') {
          // User skipped
          await intervalService.completeInterval({
            id: interval.id,
            responseType: 'skipped',
            responseTime: now,
          });
        } else {
          // User wants to log (either text or voice)
          await intervalService.completeInterval({
            id: interval.id,
            responseType: 'logged',
            responseTime: now,
          });

          // Navigate to capture screen (bottom tabs)
          const mode = actionId === 'voice' ? 'voice' : 'text';
          navigate('MainTabs', { screen: 'Capture', params: { preselectedMode: mode } });
        }

        // Check if user has skipped 3+ times recently
        const skippedCount = await intervalService.getRecentSkippedCount(6); // Last 6 hours
        if (skippedCount >= 3) {
          // Could show suggestion to adjust interval
          console.log('User has skipped 3+ times recently');
        }
      }

      // Schedule next notification
      await this.scheduleNext();
    } catch (error) {
      console.error('Failed to handle notification response:', error);
    }
  }

  /**
   * Reschedule after app restart
   */
  async reschedule(): Promise<void> {
    // Cancel any existing notifications
    await notificationService.cancelAllNotifications();

    // Check if we should schedule
    const settings = await settingsService.getSettings();
    if (settings.notificationsEnabled && settings.onboardingCompleted) {
      await this.start();
    }
  }
}

export const notificationScheduler = new NotificationScheduler();
