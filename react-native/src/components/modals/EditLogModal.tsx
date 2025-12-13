/**
 * EditLogModal Component
 * Modal for editing log entries
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  SafeAreaView,
  TouchableOpacity,
  Alert,
  ScrollView,
} from 'react-native';
import { Colors } from '../../constants/colors';
import { Button } from '../common/Button';
import { TextInput } from '../common/TextInput';
import type { Log } from '../../models/Log';

interface EditLogModalProps {
  visible: boolean;
  log: Log | null;
  onClose: () => void;
  onSave: (logId: string, content: string, category?: string) => Promise<void>;
  availableCategories: string[];
}

export const EditLogModal: React.FC<EditLogModalProps> = ({
  visible,
  log,
  onClose,
  onSave,
  availableCategories,
}) => {
  const [content, setContent] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | undefined>();
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (log) {
      setContent(log.content);
      setSelectedCategory(log.category);
    }
  }, [log]);

  const handleSave = async () => {
    if (!log) return;

    if (!content.trim()) {
      Alert.alert('Empty Content', 'Please enter log content');
      return;
    }

    try {
      setIsSaving(true);
      await onSave(log.id, content.trim(), selectedCategory);
      onClose();
    } catch (error) {
      Alert.alert('Error', 'Failed to save changes');
      console.error('Edit log error:', error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = () => {
    // Reset to original values
    if (log) {
      setContent(log.content);
      setSelectedCategory(log.category);
    }
    onClose();
  };

  if (!log) return null;

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
      onRequestClose={handleCancel}
    >
      <SafeAreaView style={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={handleCancel} style={styles.headerButton}>
            <Text style={styles.headerButtonText}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Edit Log</Text>
          <TouchableOpacity
            onPress={handleSave}
            style={styles.headerButton}
            disabled={isSaving}
          >
            <Text
              style={[
                styles.headerButtonText,
                styles.headerButtonPrimary,
                isSaving && styles.headerButtonDisabled,
              ]}
            >
              {isSaving ? 'Saving...' : 'Save'}
            </Text>
          </TouchableOpacity>
        </View>

        <ScrollView style={styles.content} contentContainerStyle={styles.contentContainer}>
          {/* Content Input */}
          <View style={styles.section}>
            <Text style={styles.sectionLabel}>Content</Text>
            <TextInput
              value={content}
              onChangeText={setContent}
              placeholder="What were you doing?"
              multiline
              numberOfLines={6}
              maxLength={500}
              showCounter
              style={styles.textInput}
              autoFocus
            />
          </View>

          {/* Category Selection */}
          <View style={styles.section}>
            <Text style={styles.sectionLabel}>Category</Text>
            <View style={styles.categoriesGrid}>
              {/* None option */}
              <TouchableOpacity
                style={[
                  styles.categoryChip,
                  !selectedCategory && styles.categoryChipSelected,
                ]}
                onPress={() => setSelectedCategory(undefined)}
                activeOpacity={0.7}
              >
                <Text
                  style={[
                    styles.categoryChipText,
                    !selectedCategory && styles.categoryChipTextSelected,
                  ]}
                >
                  None
                </Text>
              </TouchableOpacity>

              {/* Available categories */}
              {availableCategories.map((category) => (
                <TouchableOpacity
                  key={category}
                  style={[
                    styles.categoryChip,
                    selectedCategory === category && styles.categoryChipSelected,
                  ]}
                  onPress={() => setSelectedCategory(category)}
                  activeOpacity={0.7}
                >
                  <Text
                    style={[
                      styles.categoryChipText,
                      selectedCategory === category && styles.categoryChipTextSelected,
                    ]}
                  >
                    {category}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* Metadata */}
          <View style={styles.section}>
            <Text style={styles.sectionLabel}>Metadata</Text>
            <View style={styles.metadataRow}>
              <Text style={styles.metadataLabel}>Type:</Text>
              <Text style={styles.metadataValue}>
                {log.entryType === 'voice' ? '🎤 Voice' : '✍️ Text'}
              </Text>
            </View>
            <View style={styles.metadataRow}>
              <Text style={styles.metadataLabel}>Created:</Text>
              <Text style={styles.metadataValue}>
                {new Date(log.timestamp).toLocaleString()}
              </Text>
            </View>
            {log.updatedAt !== log.createdAt && (
              <View style={styles.metadataRow}>
                <Text style={styles.metadataLabel}>Updated:</Text>
                <Text style={styles.metadataValue}>
                  {new Date(log.updatedAt).toLocaleString()}
                </Text>
              </View>
            )}
          </View>
        </ScrollView>

        {/* Bottom Actions */}
        <View style={styles.footer}>
          <Button
            title="Save Changes"
            onPress={handleSave}
            fullWidth
            loading={isSaving}
            disabled={!content.trim()}
          />
        </View>
      </SafeAreaView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.black,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.grey900,
  },
  headerButton: {
    minWidth: 70,
  },
  headerButtonText: {
    fontSize: 16,
    color: Colors.grey400,
  },
  headerButtonPrimary: {
    color: Colors.white,
    fontWeight: '600',
  },
  headerButtonDisabled: {
    color: Colors.grey700,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.white,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  section: {
    marginBottom: 32,
  },
  sectionLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.grey500,
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  textInput: {
    minHeight: 150,
    textAlignVertical: 'top',
  },
  categoriesGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  categoryChip: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    backgroundColor: Colors.grey900,
    borderWidth: 1,
    borderColor: Colors.grey700,
  },
  categoryChipSelected: {
    backgroundColor: Colors.white,
    borderColor: Colors.white,
  },
  categoryChipText: {
    fontSize: 14,
    color: Colors.grey300,
    fontWeight: '500',
  },
  categoryChipTextSelected: {
    color: Colors.black,
    fontWeight: '600',
  },
  metadataRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
  },
  metadataLabel: {
    fontSize: 14,
    color: Colors.grey500,
    width: 80,
  },
  metadataValue: {
    fontSize: 14,
    color: Colors.grey300,
    flex: 1,
  },
  footer: {
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: Colors.grey900,
  },
});
