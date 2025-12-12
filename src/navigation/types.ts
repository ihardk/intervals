/**
 * Navigation types and route params
 */

import type { StackNavigationProp } from '@react-navigation/stack';
import type { RouteProp } from '@react-navigation/native';

export type RootStackParamList = {
  // Onboarding
  Welcome: undefined;
  IntervalSelection: undefined;
  Permissions: undefined;

  // Main App
  MainTabs:
    | undefined
    | {
        screen?: 'Capture' | 'History' | 'Insights' | 'Settings';
        params?: {
          preselectedMode?: 'text' | 'voice';
        };
      };
  Capture: { preselectedMode?: 'text' | 'voice' } | undefined;
  History: undefined;
  Insights: undefined;
  Settings: undefined;

  // Modals
  EditLog: { logId: string };
  CategoryManager: undefined;
};

// Navigation props for each screen
export type WelcomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Welcome'>;
export type IntervalSelectionNavigationProp = StackNavigationProp<
  RootStackParamList,
  'IntervalSelection'
>;
export type PermissionsNavigationProp = StackNavigationProp<RootStackParamList, 'Permissions'>;
export type CaptureScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Capture'>;
export type HistoryScreenNavigationProp = StackNavigationProp<RootStackParamList, 'History'>;
export type InsightsScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Insights'>;
export type SettingsScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Settings'>;

// Route props
export type CaptureScreenRouteProp = RouteProp<RootStackParamList, 'Capture'>;
export type EditLogScreenRouteProp = RouteProp<RootStackParamList, 'EditLog'>;
