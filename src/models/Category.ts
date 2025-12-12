/**
 * Category model and related types
 */

export interface Category {
  id: string;
  name: string;
  color?: string; // Hex color
  keywords: string[];
  parentCategory?: string;
  isSystem: boolean;
  createdAt: number;
  updatedAt: number;
}

export const DEFAULT_CATEGORIES: Omit<Category, 'createdAt' | 'updatedAt'>[] = [
  {
    id: 'cat_work',
    name: 'Work',
    color: '#3B82F6',
    keywords: ['coding', 'meeting', 'email', 'project', 'client', 'development', 'programming'],
    isSystem: true,
  },
  {
    id: 'cat_break',
    name: 'Break',
    color: '#10B981',
    keywords: ['break', 'coffee', 'lunch', 'rest', 'walk', 'snack'],
    isSystem: true,
  },
  {
    id: 'cat_learning',
    name: 'Learning',
    color: '#8B5CF6',
    keywords: ['reading', 'course', 'tutorial', 'studying', 'research', 'learning', 'book'],
    isSystem: true,
  },
  {
    id: 'cat_social',
    name: 'Social',
    color: '#F59E0B',
    keywords: ['chat', 'call', 'social media', 'messaging', 'talking', 'conversation'],
    isSystem: true,
  },
  {
    id: 'cat_distraction',
    name: 'Distraction',
    color: '#EF4444',
    keywords: ['browsing', 'youtube', 'scrolling', 'distracted', 'procrastinating'],
    isSystem: true,
  },
];
