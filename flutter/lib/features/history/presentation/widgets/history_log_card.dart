import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../logging/domain/entities/log.dart';
import '../../../logging/presentation/bloc/logging_bloc.dart';
import '../../../logging/presentation/bloc/logging_event.dart';
import '../widgets/edit_log_dialog.dart';

/// Log card widget with swipe actions for edit and delete
class HistoryLogCard extends StatelessWidget {
  final Log log;

  const HistoryLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
    final timeStr = DateFormat('h:mm a').format(date);
    final dateStr = DateFormat('MMM d').format(date);

    // Save this context before creating Slidable
    final cardContext = context;

    return Slidable(
      key: Key(log.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditDialog(cardContext, log),
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmation(cardContext, log),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showEditDialog(context, log),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '$dateStr · $timeStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey4,
                        ),
                      ),
                      if (log.entryType == EntryType.voice) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '🎤',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const Icon(
                    Icons.swipe_left,
                    size: 16,
                    color: AppColors.grey3,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                log.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              if (log.category != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.category!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Log log) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LoggingBloc>(),
        child: EditLogDialog(log: log),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Log log) {
    // Save the parent context before showing dialog
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grey1,
        title: const Text(
          'Delete Log?',
          style: TextStyle(color: AppColors.white),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.grey4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey4),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Use parent context, not dialog context
              parentContext.read<LoggingBloc>().add(
                    LoggingEvent.deleteLog(id: log.id),
                  );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
