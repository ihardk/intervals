/**
 * SkeletonLoader Component
 * Loading placeholder with shimmer animation
 */

import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated } from 'react-native';
import { Colors } from '../../constants/colors';

interface SkeletonLoaderProps {
  width?: number | string;
  height?: number;
  style?: any;
  variant?: 'text' | 'circle' | 'rect';
}

export const SkeletonLoader: React.FC<SkeletonLoaderProps> = ({
  width = '100%',
  height = 20,
  style,
  variant = 'rect',
}) => {
  const shimmerAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const shimmer = Animated.loop(
      Animated.sequence([
        Animated.timing(shimmerAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(shimmerAnim, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    );

    shimmer.start();

    return () => shimmer.stop();
  }, [shimmerAnim]);

  const opacity = shimmerAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.6],
  });

  const borderRadius = variant === 'circle' ? 999 : variant === 'text' ? 4 : 8;

  return (
    <Animated.View
      style={[
        styles.skeleton,
        {
          width,
          height,
          borderRadius,
          opacity,
        },
        style,
      ]}
    />
  );
};

interface SkeletonCardProps {
  showCategory?: boolean;
  showTime?: boolean;
}

export const SkeletonCard: React.FC<SkeletonCardProps> = ({
  showCategory = true,
  showTime = true,
}) => {
  return (
    <View style={styles.card}>
      {showTime && (
        <View style={styles.cardHeader}>
          <SkeletonLoader width={60} height={14} variant="text" />
        </View>
      )}
      <SkeletonLoader width="100%" height={16} variant="text" style={styles.contentLine} />
      <SkeletonLoader width="80%" height={16} variant="text" style={styles.contentLine} />
      {showCategory && (
        <SkeletonLoader width={80} height={24} variant="text" style={styles.category} />
      )}
    </View>
  );
};

interface SkeletonStatCardProps {}

export const SkeletonStatCard: React.FC<SkeletonStatCardProps> = () => {
  return (
    <View style={styles.statCard}>
      <SkeletonLoader width={60} height={32} variant="text" style={styles.statValue} />
      <SkeletonLoader width={80} height={12} variant="text" />
    </View>
  );
};

interface SkeletonListProps {
  count?: number;
  showCategory?: boolean;
}

export const SkeletonList: React.FC<SkeletonListProps> = ({ count = 3, showCategory = true }) => {
  return (
    <View style={styles.listContainer}>
      {Array.from({ length: count }).map((_, index) => (
        <SkeletonCard key={index} showCategory={showCategory} showTime />
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  skeleton: {
    backgroundColor: Colors.grey800,
  },
  card: {
    backgroundColor: Colors.grey900,
    borderRadius: 8,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.grey800,
  },
  cardHeader: {
    marginBottom: 12,
  },
  contentLine: {
    marginBottom: 8,
  },
  category: {
    marginTop: 8,
  },
  statCard: {
    backgroundColor: Colors.grey900,
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.grey800,
    minWidth: '47%',
  },
  statValue: {
    marginBottom: 8,
  },
  listContainer: {
    padding: 20,
  },
});
