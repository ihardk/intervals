import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../logging/domain/entities/log.dart';

/// Calendar heatmap widget showing daily log activity
/// Uses grayscale intensity to represent activity levels
class CalendarHeatmap extends StatefulWidget {
  final List<Log> logs;
  final Function(DateTime)? onDayTap;
  final DateTime? initialMonth;

  const CalendarHeatmap({
    super.key,
    required this.logs,
    this.onDayTap,
    this.initialMonth,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final activityMap = _buildActivityMap();

    return Column(
      children: [
        // Month navigation header
        _buildMonthHeader(),
        const SizedBox(height: 20),

        // Weekday labels
        _buildWeekdayLabels(),
        const SizedBox(height: 12),

        // Calendar grid
        _buildCalendarGrid(daysInMonth, activityMap),

        const SizedBox(height: 20),

        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.white),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.white),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, Map<String, int> activityMap) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    // Calculate total cells needed (including leading empty cells)
    final totalCells = daysInMonth + (startingWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - (startingWeekday - 1) + 1;

              if (cellIndex < startingWeekday - 1 || dayNumber > daysInMonth) {
                // Empty cell
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final dateKey = _dateToKey(date);
              final count = activityMap[dateKey] ?? 0;

              return Expanded(
                child: _buildDayCell(date, dayNumber, count),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime date, int dayNumber, int count) {
    final isToday = _isToday(date);
    final intensity = _getColorIntensity(count);

    return GestureDetector(
      onTap: () => widget.onDayTap?.call(date),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: intensity,
          borderRadius: BorderRadius.circular(4),
          border: isToday
              ? Border.all(color: AppColors.white, width: 2)
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: count > 0 ? AppColors.black : AppColors.grey5,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 2),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Less',
          style: TextStyle(fontSize: 10, color: AppColors.grey4),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getColorIntensityByLevel(index),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        const Text(
          'More',
          style: TextStyle(fontSize: 10, color: AppColors.grey4),
        ),
      ],
    );
  }

  /// Build map of date -> log count
  Map<String, int> _buildActivityMap() {
    final Map<String, int> map = {};

    for (final log in widget.logs) {
      final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
      final key = _dateToKey(date);
      map[key] = (map[key] ?? 0) + 1;
    }

    return map;
  }

  /// Get color intensity based on log count
  Color _getColorIntensity(int count) {
    if (count == 0) return AppColors.grey2;
    if (count == 1) return AppColors.grey4;
    if (count <= 3) return AppColors.grey5;
    if (count <= 5) return AppColors.grey6;
    return AppColors.white;
  }

  /// Get color intensity by level (0-4) for legend
  Color _getColorIntensityByLevel(int level) {
    switch (level) {
      case 0:
        return AppColors.grey2;
      case 1:
        return AppColors.grey4;
      case 2:
        return AppColors.grey5;
      case 3:
        return AppColors.grey6;
      case 4:
        return AppColors.white;
      default:
        return AppColors.grey2;
    }
  }

  /// Convert DateTime to date key (YYYY-MM-DD)
  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get number of days in current month
  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  /// Navigate to previous month
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  /// Navigate to next month
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }
}
