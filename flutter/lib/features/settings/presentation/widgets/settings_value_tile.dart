import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SettingsValueTile extends StatelessWidget {
  final String label;
  final String? description;
  final String value;
  final bool showArrow;
  final VoidCallback? onTap;

  const SettingsValueTile({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.showArrow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.grey4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey4,
                  size: 20,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
