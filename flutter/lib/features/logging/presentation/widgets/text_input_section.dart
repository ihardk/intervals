import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Text input section for manual activity logging
class TextInputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final FocusNode? focusNode;

  const TextInputSection({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: controller,
          placeholder: 'Type your activity...',
          maxLines: 4,
          focusNode: focusNode,
          maxLength: 500,
          autoFocus: true,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Log Activity',
          onPress: onSubmit,
        ),
      ],
    );
  }
}
