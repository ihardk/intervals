import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool autoFocus;

  const AppTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.keyboardType,
    this.focusNode,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      focusNode: focusNode,
      autofocus: autoFocus,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        height: 1.5,
      ),
      cursorColor: AppColors.white,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: AppColors.grey4),
        filled: true,
        fillColor: AppColors.grey1,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white),
        ),
        counterStyle: const TextStyle(color: AppColors.grey4),
      ),
    );
  }
}
