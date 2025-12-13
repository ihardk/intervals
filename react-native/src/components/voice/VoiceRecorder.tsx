/**
 * VoiceRecorder Component
 * Handles voice recording with waveform visualization
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Alert,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { voiceService } from '../../services/voice/VoiceService';

interface VoiceRecorderProps {
  onRecordingComplete: (transcription: string, audioPath?: string) => void;
  onCancel: () => void;
  maxDuration?: number; // in seconds
}

export const VoiceRecorder: React.FC<VoiceRecorderProps> = ({
  onRecordingComplete,
  onCancel,
  maxDuration = 120, // 2 minutes default
}) => {
  const [isRecording, setIsRecording] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [duration, setDuration] = useState(0);
  const [transcription, setTranscription] = useState('');
  const [isTranscribing, setIsTranscribing] = useState(false);

  // Animation values
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const waveformAnims = useRef(
    Array.from({ length: 20 }, () => new Animated.Value(0.2))
  ).current;

  useEffect(() => {
    if (isRecording && !isPaused) {
      // Pulse animation for recording button
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.2,
            duration: 800,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 800,
            useNativeDriver: true,
          }),
        ])
      ).start();

      // Waveform animation
      waveformAnims.forEach((anim, index) => {
        Animated.loop(
          Animated.sequence([
            Animated.timing(anim, {
              toValue: Math.random() * 0.8 + 0.2,
              duration: 300 + index * 50,
              useNativeDriver: false,
            }),
            Animated.timing(anim, {
              toValue: Math.random() * 0.5 + 0.1,
              duration: 300 + index * 50,
              useNativeDriver: false,
            }),
          ])
        ).start();
      });

      // Timer
      const interval = setInterval(() => {
        setDuration((prev) => {
          if (prev >= maxDuration) {
            handleStopRecording();
            return prev;
          }
          return prev + 1;
        });
      }, 1000);

      return () => clearInterval(interval);
    } else {
      pulseAnim.setValue(1);
      waveformAnims.forEach((anim) => anim.setValue(0.2));
    }
  }, [isRecording, isPaused]);

  const handleStartRecording = async () => {
    try {
      setDuration(0);
      setTranscription('');

      await voiceService.startRecording({
        onStart: () => {
          setIsRecording(true);
        },
        onResult: (text) => {
          setTranscription(text);
          setIsRecording(false);
          setIsTranscribing(false);
        },
        onPartialResult: (text) => {
          // Show partial results in real-time
          setTranscription(text);
        },
        onError: (error) => {
          Alert.alert('Error', `Voice recognition failed: ${error}`);
          setIsRecording(false);
          setIsTranscribing(false);
        },
        onEnd: () => {
          setIsRecording(false);
          if (!transcription) {
            setIsTranscribing(true);
          }
        },
      });
    } catch (error) {
      Alert.alert('Error', 'Failed to start recording');
      console.error('Recording error:', error);
      setIsRecording(false);
    }
  };

  const handleStopRecording = async () => {
    try {
      setIsTranscribing(true);
      await voiceService.stopRecording();
      // Transcription will come through the onResult callback
    } catch (error) {
      Alert.alert('Error', 'Failed to stop recording');
      console.error('Stop recording error:', error);
      setIsTranscribing(false);
    }
  };

  const handleCancel = async () => {
    try {
      if (voiceService.getIsRecording()) {
        await voiceService.cancelRecording();
      }
      setIsRecording(false);
      setDuration(0);
      setTranscription('');
      onCancel();
    } catch (error) {
      console.error('Cancel error:', error);
      onCancel();
    }
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (voiceService.getIsRecording()) {
        voiceService.cancelRecording();
      }
    };
  }, []);

  const handleConfirm = () => {
    if (transcription) {
      onRecordingComplete(transcription);
    }
  };

  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <View style={styles.container}>
      {/* Timer */}
      <Text style={styles.timer}>{formatDuration(duration)}</Text>

      {/* Waveform Visualization */}
      {isRecording && (
        <View style={styles.waveform}>
          {waveformAnims.map((anim, index) => (
            <Animated.View
              key={index}
              style={[
                styles.waveformBar,
                {
                  height: anim.interpolate({
                    inputRange: [0, 1],
                    outputRange: [8, 60],
                  }),
                },
              ]}
            />
          ))}
        </View>
      )}

      {/* Transcription Result */}
      {transcription && !isRecording && (
        <View style={styles.transcriptionContainer}>
          <Text style={styles.transcriptionLabel}>Transcription:</Text>
          <Text style={styles.transcriptionText}>{transcription}</Text>
        </View>
      )}

      {/* Transcribing State */}
      {isTranscribing && (
        <View style={styles.transcribingContainer}>
          <Text style={styles.transcribingText}>Transcribing...</Text>
        </View>
      )}

      {/* Controls */}
      <View style={styles.controls}>
        {!isRecording && !transcription && (
          <TouchableOpacity
            style={styles.recordButton}
            onPress={handleStartRecording}
            activeOpacity={0.7}
          >
            <Animated.View
              style={[
                styles.recordButtonInner,
                { transform: [{ scale: pulseAnim }] },
              ]}
            >
              <View style={styles.micIcon} />
            </Animated.View>
            <Text style={styles.recordButtonText}>Tap to Record</Text>
          </TouchableOpacity>
        )}

        {isRecording && (
          <View style={styles.recordingControls}>
            <TouchableOpacity
              style={styles.cancelButton}
              onPress={handleCancel}
              activeOpacity={0.7}
            >
              <Text style={styles.cancelButtonText}>✕</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.stopButton}
              onPress={handleStopRecording}
              activeOpacity={0.7}
            >
              <Animated.View
                style={[
                  styles.stopButtonInner,
                  { transform: [{ scale: pulseAnim }] },
                ]}
              />
              <Text style={styles.stopButtonText}>Stop</Text>
            </TouchableOpacity>
          </View>
        )}

        {transcription && !isRecording && !isTranscribing && (
          <View style={styles.confirmControls}>
            <TouchableOpacity
              style={styles.retryButton}
              onPress={() => {
                setTranscription('');
                handleStartRecording();
              }}
              activeOpacity={0.7}
            >
              <Text style={styles.retryButtonText}>Retry</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.confirmButton}
              onPress={handleConfirm}
              activeOpacity={0.7}
            >
              <Text style={styles.confirmButtonText}>Use This</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Status Text */}
      {isRecording && (
        <Text style={styles.statusText}>Recording... Speak clearly</Text>
      )}

      {/* Max Duration Warning */}
      {isRecording && duration >= maxDuration * 0.9 && (
        <Text style={styles.warningText}>
          {maxDuration - duration}s remaining
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    paddingVertical: 32,
    paddingHorizontal: 20,
  },
  timer: {
    fontSize: 48,
    fontWeight: '700',
    color: Colors.white,
    marginBottom: 24,
    fontVariant: ['tabular-nums'],
  },
  waveform: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: 80,
    gap: 3,
    marginBottom: 32,
  },
  waveformBar: {
    width: 4,
    backgroundColor: Colors.white,
    borderRadius: 2,
  },
  transcriptionContainer: {
    width: '100%',
    marginBottom: 24,
    padding: 16,
    backgroundColor: Colors.grey900,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: Colors.grey700,
  },
  transcriptionLabel: {
    fontSize: 12,
    color: Colors.grey500,
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  transcriptionText: {
    fontSize: 16,
    color: Colors.white,
    lineHeight: 22,
  },
  transcribingContainer: {
    marginBottom: 24,
    paddingVertical: 16,
  },
  transcribingText: {
    fontSize: 16,
    color: Colors.grey400,
  },
  controls: {
    alignItems: 'center',
    width: '100%',
  },
  recordButton: {
    alignItems: 'center',
  },
  recordButtonInner: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  micIcon: {
    width: 24,
    height: 32,
    backgroundColor: Colors.black,
    borderRadius: 12,
  },
  recordButtonText: {
    fontSize: 16,
    color: Colors.grey400,
  },
  recordingControls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 32,
  },
  cancelButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.grey900,
    borderWidth: 1,
    borderColor: Colors.grey700,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cancelButtonText: {
    fontSize: 24,
    color: Colors.grey400,
  },
  stopButton: {
    alignItems: 'center',
  },
  stopButtonInner: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: Colors.error,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 8,
  },
  stopButtonText: {
    fontSize: 16,
    color: Colors.grey400,
  },
  confirmControls: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  retryButton: {
    flex: 1,
    paddingVertical: 16,
    backgroundColor: Colors.grey900,
    borderRadius: 4,
    borderWidth: 1,
    borderColor: Colors.grey700,
    alignItems: 'center',
  },
  retryButtonText: {
    fontSize: 16,
    color: Colors.grey300,
    fontWeight: '500',
  },
  confirmButton: {
    flex: 1,
    paddingVertical: 16,
    backgroundColor: Colors.white,
    borderRadius: 4,
    alignItems: 'center',
  },
  confirmButtonText: {
    fontSize: 16,
    color: Colors.black,
    fontWeight: '600',
  },
  statusText: {
    marginTop: 16,
    fontSize: 14,
    color: Colors.grey500,
  },
  warningText: {
    marginTop: 8,
    fontSize: 14,
    color: Colors.error,
    fontWeight: '500',
  },
});
