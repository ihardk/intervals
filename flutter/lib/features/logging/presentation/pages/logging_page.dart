import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interval/features/logging/presentation/widgets/logging_input_widget.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/colors.dart';
import '../../../notifications/domain/entities/notification_action.dart';
import '../../domain/entities/log.dart';
import '../bloc/logging_bloc.dart';
import '../bloc/logging_event.dart';
import '../bloc/logging_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../features/voice/presentation/bloc/voice_bloc.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../categories/presentation/bloc/categories_state.dart';
import '../../../categories/domain/entities/category.dart';

class LoggingPage extends StatelessWidget {
  final NotificationAction? initialAction;

  const LoggingPage({super.key, this.initialAction});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.I<LoggingBloc>()..add(const LoggingEvent.loadTodayLogs()),
        ),
        BlocProvider(
          create: (_) => GetIt.I<VoiceBloc>(),
        ),
      ],
      child: LoggingView(initialAction: initialAction),
    );
  }
}

class LoggingView extends StatefulWidget {
  final NotificationAction? initialAction;

  const LoggingView({super.key, this.initialAction});

  @override
  State<LoggingView> createState() => _LoggingViewState();
}

class _LoggingViewState extends State<LoggingView> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm a').format(now);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: BlocListener<LoggingBloc, LoggingState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(message), backgroundColor: AppColors.error),
                );
              },
              success: (message, _) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.secondary),
                );
              },
              orElse: () {},
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 20),
                const Text(
                  'What are you doing now?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey4,
                  ),
                ),
                const SizedBox(height: 32),

                // Input Widget
                LoggingInputWidget(initialAction: widget.initialAction),

                const SizedBox(height: 40),

                // Recent Logs
                const Text(
                  'RECENT LOGS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey4,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                BlocBuilder<LoggingBloc, LoggingState>(
                  builder: (context, state) {
                    return _buildRecentLogsList(state);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLogsList(LoggingState state) {
    return state.maybeWhen(
      loaded: (logs, _, __) => _LogsList(logs: logs),
      success: (_, logs) => _LogsList(logs: logs),
      loading: () => const LoadingIndicator(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _LogsList extends StatelessWidget {
  final List<Log> logs;

  const _LogsList({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No logs yet today.',
            style: TextStyle(color: AppColors.grey4),
          ),
        ),
      );
    }

    // Show only top 3 recent logs
    final recentLogs = logs.take(3).toList();

    return Column(
      children: recentLogs.map((log) {
        final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
        final timeStr = DateFormat('h:mm a').format(date);

        // Color Lookup
        Color categoryColor = AppColors.grey2;
        Color textColor = AppColors.grey5;

        final categoriesState = context.read<CategoriesBloc>().state;
        if (categoriesState is CategoriesLoaded && log.category != null) {
          final category = categoriesState.categories.firstWhere(
            (c) => c.name.toLowerCase() == log.category!.toLowerCase(),
            orElse: () => Category(
                id: '',
                name: '',
                keywords: [],
                color: '',
                isSystem: false,
                createdAt: 0,
                updatedAt: 0), // Dummy
          );
          if (category.id.isNotEmpty &&
              category.color != null &&
              category.color!.isNotEmpty) {
            try {
              categoryColor =
                  Color(int.parse(category.color!.replaceAll('#', '0xff')));
              textColor = AppColors.white; // High contrast for colored chips
            } catch (_) {}
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey4,
                      ),
                    ),
                    if (log.entryType == EntryType.voice)
                      const Text(
                        '🎤 Voice',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey4,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    height: 1.4,
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
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
