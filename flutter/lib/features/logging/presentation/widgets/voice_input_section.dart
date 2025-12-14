import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../voice/presentation/bloc/voice_bloc.dart';
import '../../../voice/presentation/bloc/voice_state.dart';
import '../../../voice/presentation/bloc/voice_event.dart';

/// Voice recording interface with real-time feedback
class VoiceInputSection extends StatelessWidget {
  final ValueChanged<String> onResult;
  final VoidCallback onSubmit;

  const VoiceInputSection({
    super.key,
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
