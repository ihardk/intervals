import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../logging/domain/entities/log.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial load for current month (or reasonable range)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return BlocProvider(
      create: (_) => GetIt.I<HistoryBloc>()
        ..add(HistoryEvent.loadHistory(
          startDate: startOfMonth,
          endDate: endOfDay,
        )),
      child: const HistoryView(),
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

  // TODO: Add category filter state
  // TODO: Add view mode (List/Calendar) state

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
                    icon: const Icon(Icons.calendar_today,
                        color: AppColors.white),
                    onPressed: () {
                      // TODO: Toggle view mode
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

            // Logs List
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (msg) => Center(
                        child: Text('Error: $msg',
                            style: const TextStyle(color: AppColors.white))),
                    loaded: (logs, startDate, endDate, searchQuery,
                        filterCategory) {
                      if (logs.isEmpty) {
                        return const Center(
                            child: Text('No logs found',
                                style: TextStyle(color: AppColors.grey4)));
                      }

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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dateStr · $timeStr',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey4,
                ),
              ),
              if (log.entryType == EntryType.voice)
                const Text(
                  '🎤',
                  style: TextStyle(fontSize: 12),
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
    );
  }
}
