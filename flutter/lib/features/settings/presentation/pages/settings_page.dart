import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../features/export/presentation/bloc/export_bloc.dart';
import '../../../../features/export/presentation/bloc/export_event.dart';
import '../../../../features/export/presentation/bloc/export_state.dart';
import '../../../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_state.dart';
import '../../../../features/notifications/data/services/notification_service.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/interval_duration_picker_dialog.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle_tile.dart';
import '../widgets/settings_value_tile.dart';

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
        BlocProvider(
          create: (_) => GetIt.I<NotificationBloc>(),
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
                    loaded: (settings, _) {
                      // Schedule or Cancel based on settings
                      final notificationBloc = context.read<NotificationBloc>();

                      if (settings.notificationsEnabled) {
                        notificationBloc.add(
                          NotificationEvent.scheduleRecurring(
                            intervalDuration: settings.intervalDuration,
                            count: 50, // Schedule next 50 slots
                          ),
                        );
                      } else {
                        notificationBloc
                            .add(const NotificationEvent.cancelAll());
                      }
                    },
                    orElse: () {},
                  );
                },
                builder: (context, state) {
                  return BlocListener<NotificationBloc, NotificationState>(
                    listener: (context, notificationState) {
                      notificationState.maybeWhen(
                        error: (msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(msg),
                                backgroundColor: AppColors.error),
                          );
                        },
                        permissionsUpdated: (granted) {
                          if (!granted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Notifications disabled. Please enable them in settings.'),
                                  backgroundColor: AppColors.warning),
                            );
                          }
                        },
                        orElse: () {},
                      );
                    },
                    child: BlocListener<ExportBloc, ExportState>(
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
                        loaded: (settings, nextNotificationTime) => Column(
                          children: [
                            // Notifications Section
                            SettingsSection(
                              title: 'NOTIFICATIONS',
                              children: [
                                SettingsToggleTile(
                                  label: 'Enable Notifications',
                                  description: 'Receive interval reminders',
                                  value: settings.notificationsEnabled,
                                  onChanged: (val) {
                                    context.read<SettingsBloc>().add(
                                          SettingsEvent.toggleNotifications(
                                              val),
                                        );

                                    if (val) {
                                      // Request permissions when enabling
                                      context.read<NotificationBloc>().add(
                                            const NotificationEvent
                                                .requestPermissions(),
                                          );
                                    }
                                  },
                                ),
                                const Divider(color: AppColors.grey2),
                                SettingsValueTile(
                                  label: 'Interval Duration',
                                  description: 'How often to receive reminders',
                                  value:
                                      '${settings.intervalDurationMinutes} min',
                                  onTap: () => _showIntervalPicker(
                                    context,
                                    settings.intervalDurationMinutes,
                                  ),
                                ),
                                if (nextNotificationTime != null) ...[
                                  const Divider(color: AppColors.grey2),
                                  SettingsValueTile(
                                    label: 'Next Notification',
                                    value:
                                        '${nextNotificationTime.hour.toString().padLeft(2, '0')}:${nextNotificationTime.minute.toString().padLeft(2, '0')}',
                                    showArrow: false,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Active Hours Section
                            SettingsSection(
                              title: 'ACTIVE HOURS',
                              description:
                                  'Only receive notifications during these hours',
                              children: [
                                SettingsValueTile(
                                  label: 'Start Time',
                                  value: _formatHour(settings.activeHoursStart),
                                  onTap: () => _showHourPicker(
                                    context,
                                    settings.activeHoursStart,
                                    isStart: true,
                                  ),
                                ),
                                const Divider(color: AppColors.grey2),
                                SettingsValueTile(
                                  label: 'End Time',
                                  value: _formatHour(settings.activeHoursEnd),
                                  onTap: () => _showHourPicker(
                                    context,
                                    settings.activeHoursEnd,
                                    isStart: false,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Features Section
                            SettingsSection(
                              title: 'FEATURES',
                              children: [
                                SettingsToggleTile(
                                  label: 'Voice Input',
                                  description: 'Enable voice recording',
                                  value: settings.voiceEnabled,
                                  onChanged: (val) {
                                    context.read<SettingsBloc>().add(
                                          SettingsEvent.toggleVoice(val),
                                        );
                                  },
                                ),
                                const Divider(color: AppColors.grey2),
                                SettingsToggleTile(
                                  label: 'Auto-Categorize',
                                  description:
                                      'Automatically detect categories',
                                  value: settings.autoCategorize,
                                  onChanged: (val) {
                                    context.read<SettingsBloc>().add(
                                          SettingsEvent.toggleAutoCategorize(
                                              val),
                                        );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Data Export Section
                            SettingsSection(
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
                            SettingsSection(
                              title: 'ABOUT',
                              children: [
                                SettingsValueTile(
                                  label: 'Version',
                                  value: '1.0.0',
                                  showArrow: false,
                                ),
                                const Divider(color: AppColors.grey2),
                                SettingsValueTile(
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Debug Section
              SettingsSection(
                title: 'DEBUG',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppButton(
                      label: 'Trigger Test Notification (5s)',
                      isSecondary: true,
                      onPress: () {
                        final now = DateTime.now();
                        GetIt.I<NotificationService>().scheduleNotification(
                          id: 999, // Test ID
                          title: 'Test Notification',
                          body: 'Reply to this to test logging!',
                          scheduledTime: now.add(const Duration(seconds: 5)),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Notification scheduled in 5 seconds')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showIntervalPicker(
      BuildContext context, int currentMinutes) async {
    final selectedMinutes = await showDialog<int>(
      context: context,
      builder: (context) => IntervalDurationPickerDialog(
        initialDurationMinutes: currentMinutes < 5 ? 15 : currentMinutes,
      ),
    );

    if (selectedMinutes != null && context.mounted) {
      context.read<SettingsBloc>().add(
            SettingsEvent.updateInterval(
              selectedMinutes * 60000,
            ),
          );
    }
  }

  String _formatHour(int hour) {
    // Simple 12-hour format or 24-hour based on preference?
    // Let's use standard default formatting or a manual AM/PM construct.
    // context is needed for MaterialLocalizations, but this is a static helper or instance method.
    // We can just do manual formatting for simplicity and consistency.
    final int h = hour % 12 == 0 ? 12 : hour % 12;
    final String period = hour < 12 ? 'AM' : 'PM';
    return '$h:00 $period';
  }

  Future<void> _showHourPicker(
    BuildContext context,
    int currentHour, {
    required bool isStart,
  }) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null && context.mounted) {
      if (isStart) {
        context.read<SettingsBloc>().add(
              SettingsEvent.updateActiveHoursStart(selectedTime.hour),
            );
      } else {
        context.read<SettingsBloc>().add(
              SettingsEvent.updateActiveHoursEnd(selectedTime.hour),
            );
      }
    }
  }
}
