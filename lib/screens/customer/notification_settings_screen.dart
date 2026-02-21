import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_settings_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        actions: [
          Consumer<NotificationSettingsService>(
            builder: (context, notificationService, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset to Default',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Settings'),
                      content: const Text(
                        'Reset notification settings to default?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await notificationService.resetToDefault();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings reset to default'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationSettingsService>(
        builder: (context, notificationService, _) {
          final settings = notificationService.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appointment Reminders',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stay on top of your appointments',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: notificationService.hasAnyReminderEnabled
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: notificationService.hasAnyReminderEnabled
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              notificationService.hasAnyReminderEnabled
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: notificationService.hasAnyReminderEnabled
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notificationService.hasAnyReminderEnabled
                                    ? 'Active: ${notificationService.enabledRemindersSummary}'
                                    : 'No reminders enabled',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      notificationService.hasAnyReminderEnabled
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reminder Options
              Text(
                'REMINDER OPTIONS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Day Before Reminder
              Card(
                child: SwitchListTile(
                  title: const Text('Remind me 1 day before booking'),
                  subtitle: const Text(
                    'Get notified 24 hours before your appointment',
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  value: settings.dayBeforeReminder,
                  onChanged: (value) {
                    notificationService.toggleDayBefore(value);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Two Hours Before Reminder
              Card(
                child: SwitchListTile(
                  title: const Text('Remind me 2 hours before booking'),
                  subtitle: const Text(
                    'Get notified 2 hours before your appointment',
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  value: settings.twoHoursBeforeReminder,
                  onChanged: (value) {
                    notificationService.toggleTwoHoursBefore(value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Information Section
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'About Reminders',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        context,
                        '📱',
                        'Reminders help you never miss an appointment',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        context,
                        '⏰',
                        'You can enable both reminders for maximum coverage',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        context,
                        '✅',
                        'Settings are saved automatically',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
          ),
        ),
      ],
    );
  }
}
