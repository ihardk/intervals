/**
 * VoiceService
 * Handles voice recording and speech-to-text transcription
 */

import Voice, {
  SpeechResultsEvent,
  SpeechErrorEvent,
  SpeechStartEvent,
  SpeechEndEvent,
} from '@react-native-voice/voice';
import { Platform, PermissionsAndroid } from 'react-native';

export interface VoiceRecordingResult {
  transcription: string;
  confidence?: number;
  duration: number;
}

export interface VoiceServiceCallbacks {
  onStart?: () => void;
  onResult?: (transcription: string) => void;
  onPartialResult?: (partialTranscription: string) => void;
  onEnd?: () => void;
  onError?: (error: string) => void;
}

class VoiceService {
  private isInitialized = false;
  private isRecording = false;
  private startTime: number = 0;
  private callbacks: VoiceServiceCallbacks = {};

  constructor() {
    this.setupListeners();
  }

  /**
   * Initialize voice service
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // Request microphone permission on Android
      if (Platform.OS === 'android') {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
          {
            title: 'Microphone Permission',
            message: 'Interval needs access to your microphone for voice logging',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          }
        );

        if (granted !== PermissionsAndroid.RESULTS.GRANTED) {
          throw new Error('Microphone permission denied');
        }
      }

      this.isInitialized = true;
    } catch (error) {
      console.error('Voice initialization error:', error);
      throw error;
    }
  }

  /**
   * Setup voice recognition listeners
   */
  private setupListeners(): void {
    Voice.onSpeechStart = this.handleSpeechStart.bind(this);
    Voice.onSpeechEnd = this.handleSpeechEnd.bind(this);
    Voice.onSpeechResults = this.handleSpeechResults.bind(this);
    Voice.onSpeechPartialResults = this.handleSpeechPartialResults.bind(this);
    Voice.onSpeechError = this.handleSpeechError.bind(this);
  }

  /**
   * Event handlers
   */
  private handleSpeechStart(event: SpeechStartEvent): void {
    console.log('Speech started', event);
    this.callbacks.onStart?.();
  }

  private handleSpeechEnd(event: SpeechEndEvent): void {
    console.log('Speech ended', event);
    this.callbacks.onEnd?.();
  }

  private handleSpeechResults(event: SpeechResultsEvent): void {
    console.log('Speech results', event);
    if (event.value && event.value.length > 0) {
      const transcription = event.value[0];
      this.callbacks.onResult?.(transcription);
    }
  }

  private handleSpeechPartialResults(event: SpeechResultsEvent): void {
    console.log('Partial results', event);
    if (event.value && event.value.length > 0) {
      const partialTranscription = event.value[0];
      this.callbacks.onPartialResult?.(partialTranscription);
    }
  }

  private handleSpeechError(event: SpeechErrorEvent): void {
    console.error('Speech error', event);
    this.callbacks.onError?.(event.error?.message || 'Speech recognition error');
  }

  /**
   * Check if voice recognition is available
   */
  async isAvailable(): Promise<boolean> {
    try {
      return await Voice.isAvailable() === 1;
    } catch (error) {
      console.error('Voice availability check error:', error);
      return false;
    }
  }

  /**
   * Start voice recording
   */
  async startRecording(callbacks: VoiceServiceCallbacks = {}): Promise<void> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    if (this.isRecording) {
      throw new Error('Already recording');
    }

    try {
      this.callbacks = callbacks;
      this.startTime = Date.now();
      this.isRecording = true;

      // Start voice recognition
      await Voice.start('en-US', {
        EXTRA_LANGUAGE_MODEL: 'LANGUAGE_MODEL_FREE_FORM',
        EXTRA_MAX_RESULTS: 5,
        EXTRA_PARTIAL_RESULTS: true,
        REQUEST_PERMISSIONS_AUTO: true,
      });
    } catch (error) {
      this.isRecording = false;
      console.error('Start recording error:', error);
      throw error;
    }
  }

  /**
   * Stop voice recording
   */
  async stopRecording(): Promise<VoiceRecordingResult> {
    if (!this.isRecording) {
      throw new Error('Not recording');
    }

    try {
      await Voice.stop();

      const duration = Math.floor((Date.now() - this.startTime) / 1000);
      this.isRecording = false;

      // Wait a bit for final results
      await new Promise((resolve) => setTimeout(resolve, 500));

      // Get recognition results
      const results = await Voice.getSpeechRecognitionServices();
      console.log('Speech recognition services:', results);

      // Return result (transcription will come through callback)
      return {
        transcription: '',
        duration,
      };
    } catch (error) {
      this.isRecording = false;
      console.error('Stop recording error:', error);
      throw error;
    }
  }

  /**
   * Cancel voice recording
   */
  async cancelRecording(): Promise<void> {
    if (!this.isRecording) {
      return;
    }

    try {
      await Voice.cancel();
      this.isRecording = false;
      this.callbacks = {};
    } catch (error) {
      console.error('Cancel recording error:', error);
      throw error;
    }
  }

  /**
   * Check if currently recording
   */
  getIsRecording(): boolean {
    return this.isRecording;
  }

  /**
   * Destroy voice service
   */
  async destroy(): Promise<void> {
    try {
      if (this.isRecording) {
        await this.cancelRecording();
      }
      await Voice.destroy();
      this.isInitialized = false;
      this.callbacks = {};
    } catch (error) {
      console.error('Destroy voice service error:', error);
    }
  }

  /**
   * Get supported languages
   */
  async getSupportedLanguages(): Promise<string[]> {
    try {
      return (await Voice.getSpeechRecognitionServices()) || [];
    } catch (error) {
      console.error('Get supported languages error:', error);
      return [];
    }
  }
}

// Export singleton instance
export const voiceService = new VoiceService();
