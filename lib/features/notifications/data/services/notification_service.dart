import 'package:flutter/foundation.dart';
import 'package:shilaf/features/notifications/data/models/notification_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 通知設定を取得
  Future<NotificationSettings?> getSettings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return NotificationSettings.fromJson(response);
  }

  // 通知設定を保存/更新
  Future<void> saveSettings(NotificationSettings settings) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // 既存の設定があるか確認
    final existing = await getSettings();

    if (existing == null) {
      // 新規作成
      await _supabase.from('notification_settings').insert(settings.toJson());
    } else {
      // 更新
      await _supabase
          .from('notification_settings')
          .update(settings.toJson())
          .eq('user_id', userId);
    }
  }

  // リマインド時刻を更新
  Future<void> updateReminderTime(String time) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('notification_settings').upsert({
      'user_id': userId,
      'reminder_time': time,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // 通知のオン/オフを切り替え
  Future<void> toggleNotification(bool enabled) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('notification_settings').update({
      'is_enabled': enabled,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  // Web Push用のサブスクリプションを保存
  Future<void> saveWebPushSubscription(
      Map<String, dynamic> subscription) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('notification_settings').upsert({
      'user_id': userId,
      'web_push_subscription': subscription,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // FCMトークンを保存（モバイル用）
  Future<void> saveFCMToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('notification_settings').upsert({
      'user_id': userId,
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // 通知権限をリクエスト（プラットフォーム別）
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web Push APIの実装はJavaScript連携が必要
      return await _requestWebPushPermission();
    } else {
      // モバイルの場合はFirebase Messagingを使用
      // TODO: Firebase Messaging実装
      return false;
    }
  }

  Future<bool> _requestWebPushPermission() async {
    // Web Pushの実装は次のステップで説明
    // とりあえずtrueを返す
    return true;
  }
}
