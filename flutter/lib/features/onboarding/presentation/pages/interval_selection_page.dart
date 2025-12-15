import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';

import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../notifications/data/services/notification_service.dart';

class IntervalSelectionPage extends StatelessWidget {
  const IntervalSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I<SettingsBloc>(), // Use existing SettingsBloc
      child: const IntervalSelectionView(),
    );
  }
}

class IntervalSelectionView extends StatefulWidget {
  const IntervalSelectionView({super.key});

  @override
  State<IntervalSelectionView> createState() => _IntervalSelectionViewState();
}

class _IntervalSelectionViewState extends State<IntervalSelectionView> {
  int _selectedInterval = 30; // Default

  final List<int> _intervals = [15, 30, 45, 60];

  String _getIntervalDescription(int minutes) {
    switch (minutes) {
      case 15:
        return 'Frequent check-ins';
      case 30:
        return 'Recommended for most users';
      case 45:
        return 'For focused work sessions';
      case 60:
        return 'Hourly reflections';
      default:
        return '';
    }
  }

  Future<void> _handleContinue() async {
    // Request notification permissions
    await GetIt.I<NotificationService>().requestPermissions();

    if (!mounted) return;

    final settingsBloc = context.read<SettingsBloc>();

    // Save interval
    settingsBloc.add(SettingsEvent.updateInterval(_selectedInterval));

    // Complete onboarding
    settingsBloc.add(const SettingsEvent.completeOnboarding());

    // Navigate to Main App
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'How often should we\ncheck in?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose how frequently you'd like to log your activities.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey4,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Options
              ..._intervals.map((minutes) {
                final isSelected = minutes == _selectedInterval;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedInterval = minutes),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.grey1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.white : AppColors.grey2,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$minutes minutes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.grey3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getIntervalDescription(minutes),
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? AppColors.grey4
                                  : AppColors.grey5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),
              AppButton(
                label: 'CONTINUE',
                onPress: _handleContinue,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
