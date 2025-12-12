/**
 * HapticService Unit Tests
 */

import ReactNativeHapticFeedback from 'react-native-haptic-feedback';
import { hapticService } from '../HapticService';

// Mock the library
jest.mock('react-native-haptic-feedback');

describe('HapticService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    hapticService.setEnabled(true);
  });

  describe('setEnabled', () => {
    it('should enable haptic feedback', () => {
      hapticService.setEnabled(true);
      hapticService.trigger('selection');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalled();
    });

    it('should disable haptic feedback', () => {
      hapticService.setEnabled(false);
      hapticService.trigger('selection');
      expect(ReactNativeHapticFeedback.trigger).not.toHaveBeenCalled();
    });
  });

  describe('trigger', () => {
    it('should trigger selection haptic', () => {
      hapticService.trigger('selection');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('selection', expect.any(Object));
    });

    it('should trigger impact-light haptic', () => {
      hapticService.trigger('impact-light');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactLight', expect.any(Object));
    });

    it('should trigger impact-medium haptic', () => {
      hapticService.trigger('impact-medium');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactMedium', expect.any(Object));
    });

    it('should trigger impact-heavy haptic', () => {
      hapticService.trigger('impact-heavy');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactHeavy', expect.any(Object));
    });

    it('should trigger success haptic', () => {
      hapticService.trigger('success');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationSuccess', expect.any(Object));
    });

    it('should trigger warning haptic', () => {
      hapticService.trigger('warning');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationWarning', expect.any(Object));
    });

    it('should trigger error haptic', () => {
      hapticService.trigger('error');
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationError', expect.any(Object));
    });

    it('should default to selection for unknown type', () => {
      hapticService.trigger('unknown' as any);
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('selection', expect.any(Object));
    });

    it('should handle errors gracefully', () => {
      (ReactNativeHapticFeedback.trigger as jest.Mock).mockImplementationOnce(() => {
        throw new Error('Haptic not supported');
      });

      expect(() => hapticService.trigger('selection')).not.toThrow();
    });
  });

  describe('convenience methods', () => {
    it('should call selection()', () => {
      hapticService.selection();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('selection', expect.any(Object));
    });

    it('should call buttonPress()', () => {
      hapticService.buttonPress();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactLight', expect.any(Object));
    });

    it('should call action()', () => {
      hapticService.action();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactMedium', expect.any(Object));
    });

    it('should call success()', () => {
      hapticService.success();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationSuccess', expect.any(Object));
    });

    it('should call error()', () => {
      hapticService.error();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationError', expect.any(Object));
    });

    it('should call warning()', () => {
      hapticService.warning();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('notificationWarning', expect.any(Object));
    });

    it('should call delete()', () => {
      hapticService.delete();
      expect(ReactNativeHapticFeedback.trigger).toHaveBeenCalledWith('impactHeavy', expect.any(Object));
    });
  });
});
