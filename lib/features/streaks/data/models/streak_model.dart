/// 継続日数情報を表すモデル
/// streaksテーブルのデータ構造に対応
class StreakModel {
  final String id; // レコードのUUID
  final String userId; // ユーザーID
  final DateTime sobrietyStartDate; // 継続開始日
  final int currentStreakDays; // 現在の継続日数
  final DateTime? lastAchievementDate; // 最後に達成ボタンを押した日
  final int totalResets; // リセット回数
  final DateTime createdAt; // 作成日時
  final DateTime? updatedAt; // 更新日時

  StreakModel({
    required this.id,
    required this.userId,
    required this.sobrietyStartDate,
    required this.currentStreakDays,
    this.lastAchievementDate,
    required this.totalResets,
    required this.createdAt,
    this.updatedAt,
  });

  /// SupabaseのJSONデータからStreakModelを生成
  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sobrietyStartDate: DateTime.parse(json['sobriety_start_date'] as String),
      currentStreakDays: json['current_streak_days'] as int,
      lastAchievementDate: json['last_achievement_date'] != null
          ? DateTime.parse(json['last_achievement_date'] as String)
          : null,
      totalResets: json['total_resets'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// StreakModelをSupabaseのJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sobriety_start_date': sobrietyStartDate.toIso8601String(),
      'current_streak_days': currentStreakDays,
      'last_achievement_date': lastAchievementDate?.toIso8601String(),
      'total_resets': totalResets,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 継続開始日からの経過日数を計算
  /// ゆるいルール：開始日からの単純な日数計算
  int calculateDaysFromStart() {
    final now = DateTime.now();
    final difference = now.difference(sobrietyStartDate);
    return difference.inDays;
  }

  /// コピーを作成（一部のフィールドを更新）
  StreakModel copyWith({
    String? id,
    String? userId,
    DateTime? sobrietyStartDate,
    int? currentStreakDays,
    DateTime? lastAchievementDate,
    int? totalResets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StreakModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      lastAchievementDate: lastAchievementDate ?? this.lastAchievementDate,
      totalResets: totalResets ?? this.totalResets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
