/**
 * Minimalist color palette for Interval app
 * Black, White, and Grey spectrum
 */

export const Colors = {
  // Core colors
  black: '#000000',
  white: '#FFFFFF',

  // Grey spectrum
  grey900: '#111111',
  grey800: '#222222',
  grey700: '#333333',
  grey600: '#666666',
  grey500: '#888888',
  grey400: '#AAAAAA',
  grey300: '#CCCCCC',
  grey200: '#DDDDDD',
  grey100: '#EEEEEE',

  // Semantic colors
  background: '#000000',
  surface: '#111111',
  text: '#FFFFFF',
  textSecondary: '#AAAAAA',
  border: '#333333',
  divider: '#222222',

  // Functional colors (minimal use)
  error: '#FF4444',
  success: '#44FF44',
  warning: '#FFAA44',

  // Category colors (subtle)
  categoryWork: '#3B82F6',
  categoryBreak: '#10B981',
  categoryLearning: '#8B5CF6',
  categorySocial: '#F59E0B',
  categoryDistraction: '#EF4444',
} as const;

export type ColorName = keyof typeof Colors;
