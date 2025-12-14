import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interval/features/logging/presentation/widgets/input_mode_selector.dart';
import 'package:interval/features/logging/presentation/widgets/text_input_section.dart';
import 'package:interval/features/logging/presentation/widgets/voice_input_section.dart';
import '../../../notifications/domain/entities/notification_action.dart';
import '../bloc/logging_bloc.dart';
import '../bloc/logging_event.dart';
import '../../../../features/voice/presentation/bloc/voice_bloc.dart';
import '../../../../features/voice/presentation/bloc/voice_event.dart';

class LoggingInputWidget extends StatefulWidget {
  final NotificationAction? initialAction;
  final VoidCallback? onSuccess;

  const LoggingInputWidget({
    super.key,
    this.initialAction,
    this.onSuccess,
  });

  @override
  State<LoggingInputWidget> createState() => _LoggingInputWidgetState();
}

class _LoggingInputWidgetState extends State<LoggingInputWidget> {
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

    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
