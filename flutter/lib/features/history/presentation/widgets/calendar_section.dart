import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../logging/domain/entities/log.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/history_log_card.dart';

/// Calendar view section showing heatmap + filtered log list
class CalendarSection extends StatelessWidget {
  final List<Log> logs;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const CalendarSection({
    super.key,
    required this.logs,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Filter logs by selected date
    final displayLogs = selectedDate != null
        ? logs.where((log) {
            final logDate = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
            return logDate.year == selectedDate!.year &&
                logDate.month == selectedDate!.month &&
                logDate.day == selectedDate!.day;
          }).toList()
        : logs;

    return Column(
      children: [
        // Calendar at top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CalendarHeatmap(
            logs: logs, // Pass all logs for heatmap
            onDayTap: (date) {
              // Toggle selection: if same date, clear filter
              final isSameDate = selectedDate?.year == date.year &&
                  selectedDate?.month == date.month &&
                  selectedDate?.day == date.day;
              onDateSelected(isSameDate ? null : date);
            },
          ),
        ),

        const SizedBox(height: 20),

        // Selected date indicator
        if (selectedDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Logs for ${DateFormat('MMM d, yyyy').format(selectedDate!)}',
                  style: const TextStyle(
                    color: AppColors.grey5,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => onDateSelected(null),
                  child: const Text(
                    'Show all',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 10),

        // Filtered list
        Expanded(
          child: displayLogs.isEmpty
              ? const Center(
                  child: Text(
                    'No logs found',
                    style: TextStyle(color: AppColors.grey4),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayLogs.length,
                  itemBuilder: (context, index) {
                    final log = displayLogs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HistoryLogCard(log: log),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
