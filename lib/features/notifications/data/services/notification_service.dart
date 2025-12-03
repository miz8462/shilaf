import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final _log = Logger('NotificationService');

  Future<void> initialize() async {
    // 通知の許可をリクエスト
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _log.info('通知が許可されました');

      // FCMトークンを取得
      final vapidKey = dotenv.env['FIREBASE_VAPID_KEY'];

      String? token = await _fcm.getToken(
        vapidKey: vapidKey,
      );

      if (token != null) {
        // Supabaseにトークンを保存
        await saveTokenToSupabase(token);
      }

      // トークンの更新を監視
      _fcm.onTokenRefresh.listen(saveTokenToSupabase);
    }
  }

  Future<void> saveTokenToSupabase(String token,
      {bool? notificationEnabled, String? reminderTime}) async {
    // Supabaseに保存
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await Supabase.instance.client.from('notification_settings').upsert({
        'user_id': userId,
        'fcm_token': token,
        if (notificationEnabled != null)
          'notification_enabled': notificationEnabled,
        if (reminderTime != null) 'reminder_time': reminderTime,
      }, onConflict: 'user_id');
    }
  }
}
