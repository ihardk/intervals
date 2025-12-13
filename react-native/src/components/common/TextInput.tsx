/**
 * TextInput Component - Minimalist text input
 */

import React from 'react';
import {
  TextInput as RNTextInput,
  StyleSheet,
  View,
  Text,
  TextInputProps as RNTextInputProps,
} from 'react-native';
import { Colors } from '../../constants/colors';

interface TextInputProps extends RNTextInputProps {
  label?: string;
  error?: string;
  maxLength?: number;
  showCounter?: boolean;
}

export const TextInput = React.forwardRef<RNTextInput, TextInputProps>(
  ({ label, error, maxLength, showCounter = false, value = '', style, ...props }, ref) => {
    return (
      <View style={styles.container}>
        {label && <Text style={styles.label}>{label}</Text>}
        <RNTextInput
          ref={ref}
          style={[styles.input, error && styles.inputError, style]}
          placeholderTextColor={Colors.grey600}
          {...props}
          value={value}
          maxLength={maxLength}
        />
      <View style={styles.footer}>
        {error ? (
          <Text style={styles.error}>{error}</Text>
        ) : (
          <View />
        )}
        {showCounter && maxLength && (
          <Text style={styles.counter}>
            {value.length}/{maxLength}
          </Text>
        )}
      </View>
    </View>
  );
});

TextInput.displayName = 'TextInput';

const styles = StyleSheet.create({
  container: {
    width: '100%',
  },
  label: {
    fontSize: 14,
    color: Colors.grey400,
    marginBottom: 8,
    fontWeight: '500',
  },
  input: {
    backgroundColor: Colors.grey900,
    borderWidth: 1,
    borderColor: Colors.grey700,
    borderRadius: 4,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    color: Colors.white,
    minHeight: 52,
  },
  inputError: {
    borderColor: Colors.error,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 4,
  },
  error: {
    fontSize: 12,
    color: Colors.error,
  },
  counter: {
    fontSize: 12,
    color: Colors.grey600,
  },
});
