/**
 * Log model and related types
 */

export type EntryType = 'text' | 'voice' | 'manual';
export type TranscriptionStatus = 'pending' | 'complete' | 'failed';

export interface Log {
  id: string; // UUID v4
  timestamp: number; // Unix timestamp (ms)
  content: string; // Log text content
  entryType: EntryType; // How it was created
  audioPath?: string; // Path to audio file
  transcriptionStatus: TranscriptionStatus;
  category?: string; // Auto or manual category
  tags?: string[]; // Flexible tags
  mood?: string; // Optional mood
  createdAt: number; // Creation timestamp
  updatedAt: number; // Last update timestamp
  isDeleted: boolean; // Soft delete flag
  metadata?: Record<string, any>; // Extensible field
}

export interface CreateLogInput {
  content: string;
  entryType: EntryType;
  audioPath?: string;
  timestamp?: number; // Defaults to now
  category?: string;
  tags?: string[];
  mood?: string;
}

export interface UpdateLogInput {
  id: string;
  content?: string;
  category?: string;
  tags?: string[];
  mood?: string;
}
