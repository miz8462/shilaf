import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/features/notifications/providers/notification_settings_provider.dart';

class NotificationSettingsWidget extends ConsumerStatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  ConsumerState<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends ConsumerState<NotificationSettingsWidget> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        _selectedTime = _parseTimeOfDay(settings.reminderTime);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 通知設定タイトルとトグル
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '通知設定',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: settings.isEnabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .updateSettings(isEnabled: value);
                    },
                  ),
                ],
              ),
              // 時間設定（トグルの下に配置）
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: settings.isEnabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !settings.isEnabled,
                  child: InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Spacer(),
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: settings.isEnabled
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime.format(context),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: settings.isEnabled
                                          ? null
                                          : Theme.of(context).disabledColor,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('エラー: $err'),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      ref
          .read(notificationSettingsProvider.notifier)
          .updateSettings(reminderTime: timeString);
    }
  }
}
