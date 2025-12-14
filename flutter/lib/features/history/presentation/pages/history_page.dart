import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../logging/domain/entities/log.dart';
import '../../../logging/presentation/bloc/logging_bloc.dart';
import '../../../logging/presentation/bloc/logging_event.dart';
import '../../../logging/presentation/bloc/logging_state.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/edit_log_dialog.dart';
import '../widgets/calendar_heatmap.dart';

/// View mode for history page
enum HistoryViewMode { list, calendar }

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial load for current month (or reasonable range)
    final now = DateTime.now();
    final startOfMonth =
        DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
    final endOfMonth =
        DateTime(now.year, now.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<HistoryBloc>()
            ..add(HistoryEvent.loadHistory(
              startDate: DateTime.fromMillisecondsSinceEpoch(startOfMonth),
              endDate: DateTime.fromMillisecondsSinceEpoch(endOfMonth),
            )),
        ),
        BlocProvider(
          create: (_) => GetIt.I<LoggingBloc>(),
        ),
      ],
      child: BlocListener<LoggingBloc, LoggingState>(
        listener: (context, state) {
          state.maybeWhen(
            success: (message, logs) {
              // Refresh history after edit/delete
              context.read<HistoryBloc>().add(
                    const HistoryEvent.refreshHistory(),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: const HistoryView(),
      ),
    );
  }
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final TextEditingController _searchController = TextEditingController();
  HistoryViewMode _viewMode =
      HistoryViewMode.list; // Toggle between list and calendar
  DateTime? _selectedDate; // For filtering logs in calendar view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<HistoryBloc, HistoryState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            loaded: (logs, startDate, endDate, query, filter) =>
                                Text(
                              '${logs.length} logs ${query != null && query.isNotEmpty ? 'found' : filter != null ? 'in $filter' : 'this month'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey4,
                              ),
                            ),
                            orElse: () => const Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey4,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _viewMode == HistoryViewMode.list
                          ? Icons.calendar_month
                          : Icons.list,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _viewMode = _viewMode == HistoryViewMode.list
                            ? HistoryViewMode.calendar
                            : HistoryViewMode.list;
                        // Clear selected date when switching views
                        if (_viewMode == HistoryViewMode.list) {
                          _selectedDate = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                controller: _searchController,
                placeholder: 'Search logs...',
                onChanged: (value) {
                  context
                      .read<HistoryBloc>()
                      .add(HistoryEvent.searchHistory(value));
                },
              ),
            ),

            const SizedBox(height: 20),

            // Logs List or Calendar View
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const LoadingIndicator(),
                    error: (msg) => ErrorStateWidget(
                      message: msg,
                      onRetry: () => context
                          .read<HistoryBloc>()
                          .add(const HistoryEvent.refreshHistory()),
                    ),
                    loaded: (logs, startDate, endDate, searchQuery,
                        filterCategory) {
                      if (logs.isEmpty && _viewMode == HistoryViewMode.list) {
                        return const EmptyStateWidget(
                          message: 'No logs found',
                          icon: Icons.history,
                        );
                      }

                      // Show calendar or list based on view mode
                      if (_viewMode == HistoryViewMode.calendar) {
                        // Filter logs by selected date
                        final displayLogs = _selectedDate != null
                            ? logs.where((log) {
                                final logDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        log.timestamp);
                                return logDate.year == _selectedDate!.year &&
                                    logDate.month == _selectedDate!.month &&
                                    logDate.day == _selectedDate!.day;
                              }).toList()
                            : logs;

                        return Column(
                          children: [
                            // Calendar at top
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: CalendarHeatmap(
                                logs: logs, // Pass all logs for heatmap
                                onDayTap: (date) {
                                  setState(() {
                                    // Toggle selection: if same date, clear filter
                                    _selectedDate =
                                        (_selectedDate?.year == date.year &&
                                                _selectedDate?.month ==
                                                    date.month &&
                                                _selectedDate?.day == date.day)
                                            ? null
                                            : date;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Selected date indicator
                            if (_selectedDate != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Text(
                                      'Logs for ${DateFormat('MMM d, yyyy').format(_selectedDate!)}',
                                      style: const TextStyle(
                                        color: AppColors.grey5,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate = null;
                                        });
                                      },
                                      child: const Text(
                                        'Show all',
                                        style:
                                            TextStyle(color: AppColors.white),
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
                                        style:
                                            TextStyle(color: AppColors.grey4),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      itemCount: displayLogs.length,
                                      itemBuilder: (context, index) {
                                        final log = displayLogs[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: _HistoryLogCard(log: log),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }

                      // List view
                      // Sort by timestamp desc
                      final sortedLogs = List<Log>.from(logs)
                        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                      return RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<HistoryBloc>()
                              .add(const HistoryEvent.refreshHistory());
                          // Wait for state change or minimal delay?
                          // The bloc emits loading which rebuilds UI, so RefreshIndicator might disappear or stay.
                          // Ideally we return a Future that completes when refresh is done.
                          // But for now, basic dispatch is okay.
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: sortedLogs.length,
                          itemBuilder: (context, index) {
                            final log = sortedLogs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryLogCard(log: log),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryLogCard extends StatelessWidget {
  final Log log;

  const _HistoryLogCard({required this.log});

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
