class NotificationSettings {
  final String id;
  final String userId;
  final String reminderTime; // HH:mm形式
  final String timezone;
  final bool isEnabled;
  final String? fcmToken;
  final Map<String, dynamic>? webPushSubscription;

  NotificationSettings({
    required this.id,
    required this.userId,
    required this.reminderTime,
    this.timezone = 'Asia/Tokyo',
    this.isEnabled = true,
    this.fcmToken,
    this.webPushSubscription,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'],
      userId: json['user_id'],
      reminderTime: json['reminder_time'],
      timezone: json['timezone'] ?? 'Asia/Tokyo',
      isEnabled: json['is_enabled'] ?? true,
      fcmToken: json['fcm_token'],
      webPushSubscription: json['web_push_subscription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'reminder_time': reminderTime,
      'timezone': timezone,
      'is_enabled': isEnabled,
      'fcm_token': fcmToken,
      'web_push_subscription': webPushSubscription,
    };
  }

  NotificationSettings copyWith({
    String? id,
    String? userId,
    String? reminderTime,
    String? timezone,
    bool? isEnabled,
    String? fcmToken,
    Map<String, dynamic>? webPushSubscription,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reminderTime: reminderTime ?? this.reminderTime,
      timezone: timezone ?? this.timezone,
      isEnabled: isEnabled ?? this.isEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      webPushSubscription: webPushSubscription ?? this.webPushSubscription,
    );
  }
}
