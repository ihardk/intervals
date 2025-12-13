import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/log.dart';
import '../bloc/logging_bloc.dart';
import '../bloc/logging_event.dart';
import '../bloc/logging_state.dart';
import '../../../../features/voice/presentation/bloc/voice_bloc.dart';
import '../../../../features/voice/presentation/bloc/voice_event.dart';
import '../../../../features/voice/presentation/bloc/voice_state.dart';

class LoggingPage extends StatelessWidget {
  const LoggingPage({super.key});

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
      child: const LoggingView(),
    );
  }
}

class LoggingView extends StatefulWidget {
  const LoggingView({super.key});

  @override
  State<LoggingView> createState() => _LoggingViewState();
}

class _LoggingViewState extends State<LoggingView> {
  final TextEditingController _controller = TextEditingController();
  String _inputMode = 'text'; // 'text' or 'voice'

  @override
  void dispose() {
    _controller.dispose();
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
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: '✍️ Text',
                        isActive: _inputMode == 'text',
                        onTap: () => setState(() => _inputMode = 'text'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeButton(
                        label: '🎤 Voice',
                        isActive: _inputMode == 'voice',
                        onTap: () => setState(() => _inputMode = 'voice'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Input Section
                if (_inputMode == 'text') ...[
                  AppTextField(
                    controller: _controller,
                    placeholder: 'Type your activity...',
                    maxLines: 4,
                    maxLength: 500,
                    autoFocus: true,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Log Activity',
                    onPress: _handleSubmit,
                  ),
                ] else ...[
                  // Voice Input UI
                  _VoiceInputSection(
                    onResult: (text) {
                      setState(() {
                        _controller.text = text;
                        // Optional: Switch back to text to let user edit?
                        // _inputMode = 'text';
                      });
                    },
                    onSubmit: _handleSubmit,
                  ),
                ],

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
      loading: () => const Center(child: CircularProgressIndicator()),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _VoiceInputSection extends StatelessWidget {
  final Function(String) onResult;
  final VoidCallback onSubmit;

  const _VoiceInputSection({
    required this.onResult,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceBloc, VoiceState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (text) {
            onResult(text);
          },
          listening: (partial) {
            // Live update if needed, or wait for success
            if (partial.isNotEmpty) onResult(partial);
          },
          failure: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: AppColors.error),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isListening = state.maybeWhen(
          listening: (_) => true,
          orElse: () => false,
        );

        final text = state.maybeWhen(
          listening: (t) => t,
          success: (t) => t,
          orElse: () => 'Tap microphone to start recording',
        );

        return AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (isListening) {
                    context
                        .read<VoiceBloc>()
                        .add(const VoiceEvent.stopListening());
                  } else {
                    context
                        .read<VoiceBloc>()
                        .add(const VoiceEvent.startListening());
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isListening ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isListening)
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isListening
                    ? 'Listening...'
                    : (text.isEmpty ? 'Tap to Record' : 'Result'),
                style: const TextStyle(
                  color: AppColors.grey4,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text.isEmpty ? 'Speak clearly...' : text,
                  style: TextStyle(
                    color: text.isEmpty ? AppColors.grey5 : AppColors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isListening &&
                  text.isNotEmpty &&
                  text != 'Tap microphone to start recording') ...[
                const SizedBox(height: 24),
                AppButton(
                  label: 'Log This',
                  onPress: onSubmit,
                ),
              ],
            ],
          ),
        );
      },
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

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : AppColors.grey1,
          borderRadius: BorderRadius.circular(4),
          border: isActive
              ? Border.all(color: AppColors.white)
              : Border.all(color: AppColors.grey2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.black : AppColors.grey4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
