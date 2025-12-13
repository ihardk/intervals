/**
 * Interval timing constants
 */

export const IntervalDuration = {
  FIFTEEN_MINUTES: 15 * 60 * 1000, // 900000 ms
  THIRTY_MINUTES: 30 * 60 * 1000, // 1800000 ms
} as const;

export const AVAILABLE_INTERVALS = [
  {
    label: '15 minutes',
    value: IntervalDuration.FIFTEEN_MINUTES,
    description: 'More frequent check-ins',
  },
  {
    label: '30 minutes',
    value: IntervalDuration.THIRTY_MINUTES,
    description: 'Balanced awareness',
  },
] as const;

export const DEFAULT_INTERVAL = IntervalDuration.FIFTEEN_MINUTES;
