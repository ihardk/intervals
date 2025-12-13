/**
 * SwipeableRow Component
 * Provides swipe-to-delete/edit functionality for any content
 */

import React, { useRef } from 'react';
import { View, Text, StyleSheet, Animated, TouchableOpacity } from 'react-native';
import { Swipeable, GestureHandlerRootView } from 'react-native-gesture-handler';
import { Colors } from '../../constants/colors';
import { hapticService } from '../../services/haptics/HapticService';

interface SwipeableRowProps {
  children: React.ReactNode;
  onDelete: () => void;
  onEdit: () => void;
}

export const SwipeableRow: React.FC<SwipeableRowProps> = ({
  children,
  onDelete,
  onEdit,
}) => {
  const swipeableRef = useRef<Swipeable>(null);

  const renderRightActions = (
    progress: Animated.AnimatedInterpolation<number>,
    dragX: Animated.AnimatedInterpolation<number>
  ) => {
    // Edit button animation
    const editTranslate = progress.interpolate({
      inputRange: [0, 1],
      outputRange: [80, 0],
    });

    // Delete button animation
    const deleteTranslate = progress.interpolate({
      inputRange: [0, 1],
      outputRange: [160, 0],
    });

    const handleEdit = () => {
      hapticService.selection();
      swipeableRef.current?.close();
      onEdit();
    };

    const handleDelete = () => {
      hapticService.delete();
      swipeableRef.current?.close();
      onDelete();
    };

    return (
      <View style={styles.actionsContainer}>
        <Animated.View
          style={[
            styles.actionButton,
            styles.editButton,
            { transform: [{ translateX: editTranslate }] },
          ]}
        >
          <TouchableOpacity
            onPress={handleEdit}
            style={styles.actionTouchable}
            activeOpacity={0.7}
          >
            <Text style={styles.actionIcon}>✏️</Text>
            <Text style={styles.actionText}>Edit</Text>
          </TouchableOpacity>
        </Animated.View>

        <Animated.View
          style={[
            styles.actionButton,
            styles.deleteButton,
            { transform: [{ translateX: deleteTranslate }] },
          ]}
        >
          <TouchableOpacity
            onPress={handleDelete}
            style={styles.actionTouchable}
            activeOpacity={0.7}
          >
            <Text style={styles.actionIcon}>🗑️</Text>
            <Text style={styles.actionText}>Delete</Text>
          </TouchableOpacity>
        </Animated.View>
      </View>
    );
  };

  const handleSwipeableOpen = () => {
    hapticService.selection();
  };

  return (
    <GestureHandlerRootView>
      <Swipeable
        ref={swipeableRef}
        renderRightActions={renderRightActions}
        overshootRight={false}
        friction={2}
        rightThreshold={40}
        onSwipeableOpen={handleSwipeableOpen}
      >
        {children}
      </Swipeable>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  actionsContainer: {
    flexDirection: 'row',
    alignItems: 'stretch',
  },
  actionButton: {
    width: 80,
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionTouchable: {
    flex: 1,
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 8,
  },
  editButton: {
    backgroundColor: Colors.grey700,
  },
  deleteButton: {
    backgroundColor: Colors.error,
  },
  actionIcon: {
    fontSize: 20,
    marginBottom: 4,
  },
  actionText: {
    fontSize: 12,
    color: Colors.white,
    fontWeight: '600',
  },
});
