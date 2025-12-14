import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interval/features/logging/presentation/widgets/input_mode_selector.dart';
import 'package:interval/features/logging/presentation/widgets/text_input_section.dart';
import 'package:interval/features/logging/presentation/widgets/voice_input_section.dart';
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
import '../../../../features/voice/presentation/bloc/voice_event.dart';

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
  final TextEditingController _controller = TextEditingController();
  String _inputMode = 'text'; // 'text' or 'voice'
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Handle initial action from notification
    if (widget.initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (widget.initialAction!) {
          case NotificationAction.text:
            // Set to text mode and focus input
            setState(() {
              _inputMode = 'text';
            });
            _focusNode.requestFocus();
            break;
          case NotificationAction.voice:
            // Set to voice mode and start recording
            setState(() {
              _inputMode = 'voice';
            });
            context.read<VoiceBloc>().add(const VoiceEvent.startListening());
            break;
          case NotificationAction.skip:
            // Just open the page normally, no action needed
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty) return;

    context.read<LoggingBloc>().add(
          LoggingEvent.createLog(
            content: _controller.text.trim(),
            entryType: _inputMode, // Keep track of how it was entered
          ),
        );

    _controller.clear();
    FocusScope.of(context).unfocus();

    // Reset to text mode after logging? Optional.
    // setState(() => _inputMode = 'text');
  }

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

                // Mode Toggle
                InputModeSelector(
                  currentMode: _inputMode,
                  onModeChanged: (mode) => setState(() => _inputMode = mode),
                ),
                const SizedBox(height: 24),

                // Input Section
                if (_inputMode == 'text')
                  TextInputSection(
                    controller: _controller,
                    onSubmit: _handleSubmit,
                    focusNode: _focusNode,
                  )
                else
                  VoiceInputSection(
                    onResult: (text) {
                      setState(() {
                        _controller.text = text;
                      });
                    },
                    onSubmit: _handleSubmit,
                  ),

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
        );
      }).toList(),
    );
  }
}
