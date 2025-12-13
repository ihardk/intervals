import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPress;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPress,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.transparent : AppColors.white,
          foregroundColor: isSecondary ? AppColors.white : AppColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSecondary
                ? const BorderSide(color: AppColors.grey3)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.white : AppColors.black,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSecondary ? AppColors.white : AppColors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
