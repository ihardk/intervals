import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If onTap is provided, make it interactive
    Widget content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey1, // Surface color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey2,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
