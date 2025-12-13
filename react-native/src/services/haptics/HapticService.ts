/**
 * Haptic Service - Provides haptic feedback throughout the app
 */

import ReactNativeHapticFeedback from 'react-native-haptic-feedback';

export type HapticType =
  | 'selection' // Light tap for selections
  | 'impact-light' // Light impact for button presses
  | 'impact-medium' // Medium impact for actions
  | 'impact-heavy' // Heavy impact for important actions
  | 'success' // Success notification
  | 'warning' // Warning notification
  | 'error'; // Error notification

const hapticOptions = {
  enableVibrateFallback: true,
  ignoreAndroidSystemSettings: false,
};

class HapticService {
  private isEnabled: boolean = true;

  /**
   * Enable or disable haptic feedback
   */
  setEnabled(enabled: boolean): void {
    this.isEnabled = enabled;
  }

  /**
   * Trigger haptic feedback
   */
  trigger(type: HapticType = 'selection'): void {
    if (!this.isEnabled) return;

    try {
      switch (type) {
        case 'selection':
          ReactNativeHapticFeedback.trigger('selection', hapticOptions);
          break;
        case 'impact-light':
          ReactNativeHapticFeedback.trigger('impactLight', hapticOptions);
          break;
        case 'impact-medium':
          ReactNativeHapticFeedback.trigger('impactMedium', hapticOptions);
          break;
        case 'impact-heavy':
          ReactNativeHapticFeedback.trigger('impactHeavy', hapticOptions);
          break;
        case 'success':
          ReactNativeHapticFeedback.trigger('notificationSuccess', hapticOptions);
          break;
        case 'warning':
          ReactNativeHapticFeedback.trigger('notificationWarning', hapticOptions);
          break;
        case 'error':
          ReactNativeHapticFeedback.trigger('notificationError', hapticOptions);
          break;
        default:
          ReactNativeHapticFeedback.trigger('selection', hapticOptions);
      }
    } catch (error) {
      // Silently fail if haptics not supported
      console.debug('Haptic feedback not available:', error);
    }
  }

  /**
   * Convenience methods for common haptic patterns
   */
  selection(): void {
    this.trigger('selection');
  }

  buttonPress(): void {
    this.trigger('impact-light');
  }

  action(): void {
    this.trigger('impact-medium');
  }

  success(): void {
    this.trigger('success');
  }

  error(): void {
    this.trigger('error');
  }

  warning(): void {
    this.trigger('warning');
  }

  delete(): void {
    this.trigger('impact-heavy');
  }
}

export const hapticService = new HapticService();
