import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Toggle button selector for choosing input mode (text or voice)
class InputModeSelector extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;

  const InputModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: '✍️ Text',
            isActive: currentMode == 'text',
            onTap: () => onModeChanged('text'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeButton(
            label: '🎤 Voice',
            isActive: currentMode == 'voice',
            onTap: () => onModeChanged('voice'),
          ),
        ),
      ],
    );
  }
}

/// Individual mode button
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : AppColors.grey2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.black : AppColors.grey5,
          ),
        ),
      ),
    );
  }
}
