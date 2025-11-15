class DailyAchievement {
  final String id;
  final String userId;
  final String streakId;
  final DateTime date;
  final DateTime createdAt;

  DailyAchievement({
    required this.id,
    required this.userId,
    required this.streakId,
    required this.date,
    required this.createdAt,
  });

  factory DailyAchievement.fromJson(Map<String, dynamic> json) {
    return DailyAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      streakId: json['streak_id'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'streak_id': streakId,
      'date': _formatDate(date),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 日付をYYYY-MM-DD形式にフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'DailyAchievement(id: $id, userId: $userId, streakId: $streakId, date: $date)';
  }
}
