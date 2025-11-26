import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettings {
  final bool isEnabled;
  final String reminderTime;

  const NotificationSettings({
    required this.isEnabled,
    required this.reminderTime,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    String? reminderTime,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    return await _loadSettings();
  }

  Future<NotificationSettings> _loadSettings() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        return const NotificationSettings(
            isEnabled: false, reminderTime: '09:00');
      }

      final response = await Supabase.instance.client
          .from('user_tokens')
          .select('notification_enabled, reminder_time')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return const NotificationSettings(
            isEnabled: false, reminderTime: '09:00');
      } else {
        return NotificationSettings(
          isEnabled: response['notification_enabled'] ?? false,
          reminderTime: response['reminder_time'] ?? '09:00',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSettings({bool? isEnabled, String? reminderTime}) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newSettings = currentState.copyWith(
      isEnabled: isEnabled,
      reminderTime: reminderTime,
    );

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // まず現在のFCMトークンを取得
      final existingToken = await Supabase.instance.client
          .from('user_tokens')
          .select('fcm_token')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingToken == null) {
        // FCMトークンがない場合は通知設定のみを保存
        await Supabase.instance.client.from('user_tokens').upsert({
          'user_id': userId,
          'fcm_token': '',
          'notification_enabled': newSettings.isEnabled,
          'reminder_time': newSettings.reminderTime,
        }, onConflict: 'user_id');
      } else {
        // FCMトークンがある場合は更新
        await Supabase.instance.client.from('user_tokens').upsert({
          'user_id': userId,
          'fcm_token': existingToken['fcm_token'],
          'notification_enabled': newSettings.isEnabled,
          'reminder_time': newSettings.reminderTime,
        }, onConflict: 'user_id');
      }

      state = AsyncValue.data(newSettings);
    } catch (e) {
      // エラーをログに出力して、状態は更新する
      debugPrint('通知設定更新エラー: $e');
      state = AsyncValue.data(newSettings);
    }
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        () {
  return NotificationSettingsNotifier();
});
