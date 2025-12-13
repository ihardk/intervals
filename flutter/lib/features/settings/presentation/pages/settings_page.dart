import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../features/export/presentation/bloc/export_bloc.dart';
import '../../../../features/export/presentation/bloc/export_event.dart';
import '../../../../features/export/presentation/bloc/export_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetIt.I<SettingsBloc>()..add(const SettingsEvent.loadSettings()),
        ),
        BlocProvider(
          create: (_) => GetIt.I<ExportBloc>(),
        ),
      ],
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),

              BlocConsumer<SettingsBloc, SettingsState>(
                listener: (context, state) {
                  state.maybeWhen(
                    error: (msg) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(msg),
                            backgroundColor: AppColors.error),
                      );
                    },
                    orElse: () {},
                  );
                },
                builder: (context, state) {
                  return BlocListener<ExportBloc, ExportState>(
                    listener: (context, exportState) {
                      exportState.maybeWhen(
                        success: (path) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Exported to $path'),
                                backgroundColor: AppColors.success),
                          );
                        },
                        error: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(msg),
                                backgroundColor: AppColors.error),
                          );
                        },
                        orElse: () {},
                      );
                    },
                    child: state.maybeWhen(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      loaded: (settings) => Column(
                        children: [
                          // Notifications Section
                          _Section(
                            title: 'NOTIFICATIONS',
                            children: [
                              _SettingToggle(
                                label: 'Enable Notifications',
                                description: 'Receive interval reminders',
                                value: settings.notificationsEnabled,
                                onChanged: (val) {
                                  context.read<SettingsBloc>().add(
                                        SettingsEvent.toggleNotifications(val),
                                      );
                                },
                              ),
                              const Divider(color: AppColors.grey2),
                              _SettingValueRow(
                                label: 'Interval Duration',
                                description: 'How often to receive reminders',
                                value: '${settings.intervalDuration} min',
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Features Section
                          _Section(
                            title: 'FEATURES',
                            children: [
                              _SettingToggle(
                                label: 'Voice Input',
                                description:
                                    'Enable voice recording (Coming Soon)',
                                value: settings.voiceEnabled,
                                onChanged: (val) {
                                  context.read<SettingsBloc>().add(
                                        SettingsEvent.toggleVoice(val),
                                      );
                                },
                              ),
                              const Divider(color: AppColors.grey2),
                              _SettingToggle(
                                label: 'Auto-Categorize',
                                description: 'Automatically detect categories',
                                value: settings.autoCategorize,
                                onChanged: (val) {
                                  context.read<SettingsBloc>().add(
                                        SettingsEvent.toggleAutoCategorize(val),
                                      );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Data Export Section
                          _Section(
                            title: 'DATA EXPORT',
                            description: 'Export your logs from this month',
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    AppButton(
                                      label: 'Export to CSV',
                                      isSecondary: true,
                                      onPress: () {
                                        context.read<ExportBloc>().add(
                                              ExportEvent.exportToCsv(
                                                startDate: DateTime.now()
                                                    .subtract(const Duration(
                                                        days: 30))
                                                    .toIso8601String(),
                                                endDate: DateTime.now()
                                                    .toIso8601String(),
                                              ),
                                            );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    AppButton(
                                      label: 'Export to JSON',
                                      isSecondary: true,
                                      onPress: () {
                                        context.read<ExportBloc>().add(
                                              ExportEvent.exportToJson(
                                                startDate: DateTime.now()
                                                    .subtract(const Duration(
                                                        days: 30))
                                                    .toIso8601String(),
                                                endDate: DateTime.now()
                                                    .toIso8601String(),
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // About Section
                          _Section(
                            title: 'ABOUT',
                            children: [
                              _SettingValueRow(
                                label: 'Version',
                                value: '1.0.0',
                                showArrow: false,
                              ),
                              const Divider(color: AppColors.grey2),
                              _SettingValueRow(
                                label: 'Build',
                                value: 'MVP Alpha',
                                showArrow: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const _Section({
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey4,
            letterSpacing: 0.5,
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
        const SizedBox(height: 8),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey4,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.grey3,
            inactiveThumbColor: AppColors.grey4,
            inactiveTrackColor: AppColors.grey2,
          ),
        ],
      ),
    );
  }
}

class _SettingValueRow extends StatelessWidget {
  final String label;
  final String? description;
  final String value;
  final bool showArrow;

  const _SettingValueRow({
    required this.label,
    this.description,
    required this.value,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
  }
}
